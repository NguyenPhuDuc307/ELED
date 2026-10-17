"""Rebuild bilingual meanings from the Vietnamese Wiktionary extract.
Usage: python3 tools/rebuild_meanings.py /path/to/vi-extract.jsonl.gz [--apply]
Exact headword/POS matches only; unmatched CSV rows stay unchanged.
"""
import argparse, collections, csv, gzip, hashlib, json, re, unicodedata
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
POS = {'adj':'adjective','adv':'adverb','noun':'noun','verb':'verb','prep':'preposition','pron':'pronoun','conj':'conjunction','intj':'exclamation','num':'number','det':'determiner','article':'determiner','abbrev':'abbreviation','prefix':'prefix','suffix':'suffix','name':'proper noun','phrase':'phrase'}
BAD_TAGS = {'obsolete','archaic','dated','rare','form-of','alt-of','misspelling'}
def key(text): return unicodedata.normalize('NFC', text).strip().casefold()
def parts(text):
    return set('number' if p.strip() == 'ordinal number' else 'determiner' if p.strip() in {'indefinite article','definite article'} else p.strip() for p in re.split('[;,]', text) if p.strip())
def canonical(pos): return 'verb' if pos in {'phrasal verb','modal verb','auxiliary verb'} else pos
def clean(text):
    text = re.sub(r'\s+', ' ', text).strip(' ;.').replace('... )', '...)')
    if not text or len(text)>300 or re.match(r'^(?:xem|như|viết tắt của|số nhiều của|quá khứ.*của|phân từ.*của)\b',text,re.I): return None
    if not re.search(r'[À-ỹĐđ]',text) or re.search(r'\b(?:từ cổ|nghĩa cổ|ít dùng|lỗi thời)\b',text,re.I): return None
    return text[0].lower()+text[1:]
def build(source):
    paths=sorted((ROOT/'assets/data').rglob('*.csv'))
    allowed=collections.defaultdict(set); original={}; files={}
    for path in paths:
        with path.open(encoding='utf-8-sig',newline='') as f: rows=list(csv.DictReader(f))
        files[path]=rows
        for row in rows:
            k=key(row['word']); allowed[k].update(parts(row['part_of_speech'])); original.setdefault(k,row['translation'])
    lookup=collections.defaultdict(list)
    for k in allowed:
        lookup[k].append(k)
        match=re.fullmatch(r"([a-z]+)[12]",k)
        if match:
            stem=match[1]
            if any(key(row['word'])==k and re.search(r'/'+re.escape(stem)+r'_[12](?:$|[?#])',row['url']) for rows in files.values() for row in rows): lookup[stem].append(k)
    candidates=collections.defaultdict(lambda:collections.defaultdict(list))
    with gzip.open(source,'rt',encoding='utf8') as f:
        for line in f:
            entry=json.loads(line); source_key=key(entry.get('word','')); pos=POS.get(entry.get('pos'))
            if entry.get('lang_code')!='en' or source_key not in lookup: continue
            senses=[]
            for sense in entry.get('senses',[]):
                if BAD_TAGS.intersection(sense.get('tags',[])): continue
                if sense.get('form_of') or sense.get('alt_of'): continue
                for gloss in sense.get('glosses',[]):
                    value=clean(gloss)
                    if value and value not in senses: senses.append(value)
            if senses:
                for k in lookup[source_key]:
                    for target in allowed[k]:
                        if canonical(target)==pos: candidates[k][target].append(senses)
    result={}
    for k, groups in sorted(candidates.items()):
        result[k]={}
        for pos, entries in groups.items():
            # Round-robin across homographs; do not lose a second noun/verb entry.
            values=[]
            for index in range(max(map(len,entries))):
                for entry in entries:
                    if index<len(entry) and entry[index] not in values: values.append(entry[index])
            result[k][pos]=values[:6]
    overrides=json.loads((ROOT/'assets/lexicon/reviewed.json').read_text())
    for k, groups in overrides.items():
        if k not in allowed: raise ValueError('Unknown reviewed headword: '+k)
        result.setdefault(k,{}).update({p:v for p,v in groups.items() if p in allowed[k]})
    changed=[]; unresolved=[]
    for path, rows in files.items():
        for row in rows:
            k=key(row['word']); groups=result.get(k,{})
            matching=[p for p in parts(row['part_of_speech']) if p in groups]
            if not matching:
                unresolved.append({'word':row['word'],'pos':row['part_of_speech'],'meaning':row['translation'],'file':str(path.relative_to(ROOT))})
                continue
            values=[]
            for p in sorted(matching):
                for v in groups[p][:1]:
                    if v not in values: values.append(v)
            meaning='; '.join(values)
            if meaning!=row['translation']:
                changed.append({'word':row['word'],'pos':row['part_of_speech'],'before':row['translation'],'after':meaning})
                row['translation']=meaning
    return result,files,changed,unresolved,allowed
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('source',type=Path);parser.add_argument('--apply',action='store_true');args=parser.parse_args()
    result,files,changed,unresolved,allowed=build(args.source)
    summary={'source':'https://kaikki.org/dictionary/downloads/vi/vi-extract.jsonl.gz','sha256':hashlib.sha256(args.source.read_bytes()).hexdigest(),'total_words':len(allowed),'matched_words':len(result),'changed_rows':len(changed),'unmatched_words':len({key(r['word']) for r in unresolved}),'unmatched_rows':len(unresolved)}
    summary.update(fully_matched_words=sum(bool(v) and v.issubset(result.get(k,{})) for k,v in allowed.items()), partially_matched_words=sum(k in result and not v.issubset(result[k]) for k,v in allowed.items()), words_without_matched_meanings=len(allowed)-len(result), changed_unique_words=len({key(r['word']) for r in changed}))
    out=ROOT/'assets/lexicon'
    (out/'audit.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
    (out/'unmatched.json').write_text(json.dumps(unresolved,ensure_ascii=False,indent=2)+'\n')
    (out/'changes.json').write_text(json.dumps(changed,ensure_ascii=False,indent=2)+'\n')
    (out/'meanings.json').write_text(json.dumps(result,ensure_ascii=False,separators=(',',':'))+'\n')
    if args.apply:
        for path,rows in files.items():
            with path.open('w',encoding='utf8',newline='') as f:
                writer=csv.DictWriter(f,fieldnames=list(rows[0]),lineterminator='\n');writer.writeheader();writer.writerows(rows)
    print(json.dumps(summary,ensure_ascii=False))
