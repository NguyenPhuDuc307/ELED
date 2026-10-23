"""Translate headwords with Google Translate; checkpoint every batch, resume safely.
Run: python3 tools/google_translate_vocabulary.py [--apply]
--apply updates CSV translations and the web meaning override after completion.
"""
import argparse
import concurrent.futures
import csv
import io
import json
import re
from pathlib import Path
import time
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
CACHE = ROOT / 'output/google/checkpoint.json'
APPLIED = ROOT / 'assets/lexicon/google-translations.json'
SOURCE_WORDS = {}

def translate(words):
    query = urllib.parse.urlencode(dict(client='gtx', sl='en', tl='vi', dt='t', q='\n'.join(re.sub(r'(?<=[a-zA-Z])[12]$', '', SOURCE_WORDS.get(word, word)) for word in words)))
    request = urllib.request.Request('https://translate.googleapis.com/translate_a/single?' + query)
    with urllib.request.urlopen(request, timeout=30) as response:
        data = json.load(response)
    lines = ''.join(part[0] for part in data[0] if isinstance(part[0], str)).strip().splitlines()
    if len(lines) != len(words) or any(not line.strip() for line in lines):
        if len(words) == 1:
            raise ValueError('Invalid translation for ' + words[0])
        return {word: translate([word])[word] for word in words}
    return dict(zip(words, (line.strip() for line in lines)))

def save(data):
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    temporary = CACHE.with_suffix('.tmp')
    temporary.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    temporary.replace(CACHE)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--limit', type=int)
    args = parser.parse_args()
    paths = sorted((ROOT / 'assets/data').rglob('*.csv'))
    words = {}
    for path in paths:
        with path.open(newline='') as stream:
            for row in csv.DictReader(stream):
                word = row['word'].strip().lower()
                if word and '\n' not in word and not word.startswith(('http://', 'https://')):
                    words.setdefault(word, row['word'].strip())
    SOURCE_WORDS.update(words)
    data = json.loads(CACHE.read_text()) if CACHE.exists() else {}
    pending = [word for word in words if word not in data]
    if args.limit is not None:
        pending = pending[:args.limit]
    batches = [pending[i:i+50] for i in range(0, len(pending), 50)]
    # Bounded concurrency; provider failures stop the run. No automatic retries
    # of rate limits. Completed batches remain available for the next run.
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        for offset in range(0, len(batches), 3):
            results = pool.map(translate, batches[offset:offset+3])
            for result in results:
                data.update(result)
                save(data)
                print(f'{len(data)}/{len(words)} translated', flush=True)
            time.sleep(0.5)
    if args.apply:
        missing = set(words) - data.keys()
        if missing:
            raise ValueError(f'Refusing partial apply: {len(missing)} words missing')
        for path in paths:
            with path.open(newline='') as stream:
                reader = csv.DictReader(stream)
                fields = reader.fieldnames
                rows = list(reader)
            for row in rows:
                key = row['word'].strip().lower()
                if key in data:
                    row['translation'] = data[key]
            output = io.StringIO(newline='')
            writer = csv.DictWriter(output, fieldnames=fields, lineterminator='\n')
            writer.writeheader()
            writer.writerows(rows)
            path.write_text(output.getvalue())
        APPLIED.write_text(json.dumps({word: data[word] for word in words}, ensure_ascii=False, indent=2) + '\n')
        print('Applied Google translations to CSV vocabulary.', flush=True)

if __name__ == '__main__':
    main()
