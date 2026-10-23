#!/usr/bin/env python3
"""Import the FVDP DictionaryForMIDs archive into a separate SQLite review DB.
No production credentials, no automatic app vocabulary writes, no JAR execution.
"""
import argparse
import collections
import csv
import hashlib
import io
import json
import re
import sqlite3
import unicodedata
from datetime import datetime, timezone
from pathlib import Path
from zipfile import ZipFile

SOURCE_URL = 'https://downloads.sourceforge.net/project/dictionarymid/dictionary%20EngVie/3.0/DictionaryForMIDs_3.0.0_EngVie_109k.zip'
POS = {'dtừ': 'noun', 'danh từ': 'noun', 'ttừ': 'adjective', 'tính từ': 'adjective',
       'phtừ': 'adverb', 'phó từ': 'adverb', 'ngđtừ': 'verb', 'nđtừ': 'verb',
       'đtừ': 'verb', 'động từ': 'verb', 'gttừ': 'preposition', 'giới từ': 'preposition',
       'liên từ': 'conjunction', 'đại từ': 'pronoun', 'thán từ': 'exclamation',
       'số từ': 'number', 'mạo từ': 'determiner'}
REGRESSIONS = {
    'plane': ('noun', 'cây tiêu huyền'), 'nurse': ('noun', 'cá nhám'),
    'clock': ('noun', 'đường chỉ viền'), 'sweater': ('noun', 'người ra nhiều mồ hôi'),
    'popular': ('adjective', 'nhân dân'), 'player': ('noun', 'cầu thủ'),
    'could': ('verb', 'đóng hộp'),
}


def key(s):
    return unicodedata.normalize('NFC', s).strip().casefold()


def unmark(s):
    # Formatting markers nest; unwrap from the inside out without deleting text.
    while re.search(r'\[\d\d[^\[\]]*\]', s):
        s = re.sub(r'\[\d\d([^\[\]]*)\]', r'\1', s)
    return re.sub(r'\s+', ' ', s).strip()


def parse_body(body):
    senses, examples, labels = [], [], []
    pos, label, idiom = None, None, False
    for raw in body.split('\\n'):
        marker = re.match(r'^\[01\*\s*([^\]]+)\]', raw)
        if marker:
            label = marker[1].strip()
            pos = POS.get(label)
            labels.append({'raw': label, 'normalized': pos})
            idiom = False
            raw = raw[marker.end():].strip()
        if raw.startswith('[04!'):
            idiom = True
        example = re.match(r'^\[02=\s*(.*?)\]\s*(.*)$', raw)
        if example:
            examples.append({'en': unmark(example[1]), 'vi': unmark(example[2]), 'idiom': idiom})
        if raw.startswith('-') and not idiom:
            gloss = unmark(raw.lstrip('-').strip())
            if gloss:
                senses.append({'pos': pos, 'raw_pos': label, 'gloss': gloss})
    return {'senses': senses, 'examples': examples, 'pos_labels': labels}


def archive_entries(path):
    with ZipFile(path) as outer:
        jar_names = [n for n in outer.namelist() if n.endswith('EngVie.jar')]
        if len(jar_names) != 1:
            raise ValueError('Expected exactly one EngVie.jar')
        # Read zip members directly; never extract arbitrary paths or execute classes.
        with ZipFile(io.BytesIO(outer.read(jar_names[0]))) as jar:
            names = sorted((n for n in jar.namelist() if re.fullmatch(r'dictionary/directoryEng\d+\.csv', n)),
                           key=lambda n: int(re.search(r'(\d+)\.csv$', n)[1]))
            if not names:
                raise ValueError('No English dictionary chunks found')
            for name in names:
                for line_number, line in enumerate(jar.read(name).decode('utf-8').splitlines(), 1):
                    header, sep, body = line.partition('\t')
                    if not sep:
                        raise ValueError(f'Malformed source row {name}:{line_number}')
                    headword = unmark(re.split(r'\s+\[01', header, maxsplit=1)[0])
                    if not headword:
                        raise ValueError(f'Empty headword {name}:{line_number}')
                    yield name, line_number, headword, body, parse_body(body)


def stage(archive, vocabulary, database, report_path):
    archive_hash = hashlib.sha256(archive.read_bytes()).hexdigest()
    rows = json.loads(vocabulary.read_text())
    if not isinstance(rows, list) or any(not isinstance(r,list) or len(r)<8 for r in rows):
        raise ValueError('Expected ELED vocabulary row arrays')
    now = datetime.now(timezone.utc).isoformat()
    database.parent.mkdir(parents=True, exist_ok=True)
    if database.exists():
        raise ValueError(f'{database} already exists; use a new output path to preserve prior review')
    db = sqlite3.connect(database)
    try:
        with db:
            db.executescript('''
                create table sources(id integer primary key,url text not null,sha256 text not null,imported_at text not null);
                create table source_entries(id integer primary key,word_key text not null,headword text not null,
                  source_file text not null,source_line integer not null,raw_body text not null,parsed_json text not null);
                create index source_entries_word on source_entries(word_key);
                create table app_words(word_key text primary key,payload_json text not null);
                create table comparisons(word_key text primary key,match_status text not null,
                  source_entry_ids text not null,current_meanings text not null,candidate_meanings text not null,
                  review_status text not null default 'needs_review');
            ''')
            db.execute('insert into sources values(1,?,?,?)',(SOURCE_URL,archive_hash,now))
            count = 0
            for name, line, headword, body, parsed in archive_entries(archive):
                db.execute('insert into source_entries(word_key,headword,source_file,source_line,raw_body,parsed_json) values(?,?,?,?,?,?)',
                           (key(headword),headword,name,line,body,json.dumps(parsed,ensure_ascii=False)))
                count += 1
            statuses = collections.Counter()
            pos_groups = collections.Counter()
            regression = []
            for row in rows:
                word = key(row[0])
                matches = db.execute('select id,parsed_json from source_entries where word_key=?',(word,)).fetchall()
                candidates = collections.defaultdict(list)
                for _, parsed in matches:
                    for sense in json.loads(parsed)['senses']:
                        if sense['pos'] and sense['gloss'] not in candidates[sense['pos']]:
                            candidates[sense['pos']].append(sense['gloss'])
                current = dict(row[8]) if len(row)>8 else {}
                statuses['matched_headword' if matches else 'missing_headword'] += 1
                for pos in current:
                    pos_groups['matched' if pos in candidates else 'missing'] += 1
                status = 'matched_pos' if matches and any(p in candidates for p in current) else 'headword_only' if matches else 'not_found'
                db.execute('insert into app_words values(?,?)',(word,json.dumps(row,ensure_ascii=False)))
                db.execute('insert into comparisons(word_key,match_status,source_entry_ids,current_meanings,candidate_meanings) values(?,?,?,?,?)',
                           (word,status,json.dumps([m[0] for m in matches]),json.dumps(current,ensure_ascii=False),json.dumps(candidates,ensure_ascii=False)))
                if word in REGRESSIONS:
                    pos, bad = REGRESSIONS[word]
                    values = candidates.get(pos,[])
                    regression.append({'word':word,'pos':pos,'current':current.get(pos,[]),'source_candidates':values,
                                       'known_problem_present':any(bad in s for s in values),
                                       'problem_is_first':bool(values and bad in values[0])})
            report = {'source_url':SOURCE_URL,'source_sha256':archive_hash,'imported_at':now,
                      'source_records':count,'app_words':len(rows),'headword_coverage':dict(statuses),
                      'pos_group_coverage':dict(pos_groups),'regression_checks':regression,
                      'decision':('Do not replace production meanings automatically. Known problematic senses recur in this source.'
                                  if any(c['problem_is_first'] for c in regression) else 'Manual sense review required before any production update.'),
                      'automatically_approved':0,'production_changes':0,
                      'license_note':'Archive COPYING is GPL v2 for the Java application; README directs dictionary copyright to other metadata. Retained archive for further data-license verification.'}
        report_path.parent.mkdir(parents=True,exist_ok=True)
        report_path.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
        export_comparisons(db, report_path.with_suffix('.csv'))
        return report
    except Exception:
        db.close()
        database.unlink(missing_ok=True)
        raise
    finally:
        db.close()



def export_comparisons(db, path):
    with path.open('w', encoding='utf-8-sig', newline='') as stream:
        writer=csv.writer(stream)
        writer.writerow(['word','match_status','current_meanings','source_candidates','review_status'])
        for row in db.execute('select word_key,match_status,current_meanings,candidate_meanings,review_status from comparisons order by word_key'):
            # Prevent spreadsheet formulas when viewing external headwords/glosses.
            writer.writerow(["'"+v if isinstance(v,str) and v.startswith(('=','+','-','@')) else v for v in row])


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--archive',type=Path,required=True)
    p.add_argument('--vocabulary',type=Path,default=Path('apps/web/public/vocabulary.json'))
    p.add_argument('--database',type=Path,default=Path('output/fvdp/review.sqlite'))
    p.add_argument('--report',type=Path,default=Path('output/fvdp/report.json'))
    a=p.parse_args()
    r=stage(a.archive,a.vocabulary,a.database,a.report)
    print(json.dumps({k:v for k,v in r.items() if k!='regression_checks'},ensure_ascii=False,indent=2))

if __name__=='__main__':main()
