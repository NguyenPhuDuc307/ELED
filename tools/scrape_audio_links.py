#!/usr/bin/env python3
"""
Scrape audio URLs from Oxford Learner's Dictionary and update all CSVs.
Strategy:
  1. Reuse audio links already present in popularity CSVs (known correct).
  2. Scrape Oxford pages for topic-only words (not in popularity).
  3. Cache scraped results to audio_cache.json to allow resuming.
"""

import csv
import glob
import json
import os
import re
import time
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock

import requests

BASE        = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
CACHE_FILE  = os.path.join(os.path.dirname(__file__), 'audio_cache.json')
CONCURRENCY = 8
DELAY       = 0.15  # seconds between requests per thread

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html',
}

AUDIO_RE = re.compile(r'data-src-mp3="([^"]+_gb_\d+\.mp3)"')


# ── helpers ──────────────────────────────────────────────────────────────────

def fetch_audio(session: requests.Session, oxford_url: str) -> str:
    """Return first UK MP3 URL found on the Oxford page, or ''."""
    for attempt in range(4):
        try:
            r = session.get(oxford_url, headers=HEADERS, timeout=15)
            if r.status_code == 429:
                time.sleep(5 * (attempt + 1))
                continue
            if r.status_code != 200:
                return ''
            m = AUDIO_RE.search(r.text)
            return m.group(1) if m else ''
        except Exception:
            time.sleep(2 * (attempt + 1))
    return ''


def build_pop_map() -> dict[str, str]:
    """word.lower() → audio URL from popularity CSVs."""
    result: dict[str, str] = {}
    for f in sorted(glob.glob(os.path.join(BASE, 'popularity', '*.csv'))):
        with open(f, newline='', encoding='utf-8') as fp:
            for i, row in enumerate(csv.reader(fp)):
                if i == 0 or len(row) < 8:
                    continue
                word, audio = row[3].strip().lower(), row[7].strip()
                if word and audio:
                    result[word] = audio
    return result


def collect_scrape_targets(pop_map: dict) -> dict[str, str]:
    """oxford_url → '' for topic entries whose word is not in pop_map."""
    targets: dict[str, str] = {}
    for f in sorted(glob.glob(os.path.join(BASE, 'topic', '**', '*.csv'), recursive=True)):
        with open(f, newline='', encoding='utf-8') as fp:
            for i, row in enumerate(csv.reader(fp)):
                if i == 0 or len(row) < 4:
                    continue
                word = row[3].strip().lower()
                url  = row[1].strip()
                if url and word and word not in pop_map and url not in targets:
                    targets[url] = ''
    return targets


def load_cache() -> dict[str, str]:
    if os.path.exists(CACHE_FILE):
        with open(CACHE_FILE, encoding='utf-8') as f:
            return json.load(f)
    return {}


def save_cache(cache: dict[str, str]):
    with open(CACHE_FILE, 'w', encoding='utf-8') as f:
        json.dump(cache, f, indent=2, ensure_ascii=False)


# ── scrape ────────────────────────────────────────────────────────────────────

def scrape_missing(targets: dict[str, str], cache: dict[str, str]) -> dict[str, str]:
    """Fill targets dict by scraping Oxford; returns updated targets."""
    to_fetch = [u for u in targets if u not in cache]
    print(f'  Cached: {len(targets) - len(to_fetch)}  |  To fetch: {len(to_fetch)}')
    if not to_fetch:
        return {**targets, **{u: cache[u] for u in targets if u in cache}}

    lock  = Lock()
    done  = [0]
    total = len(to_fetch)

    def worker(url):
        session = requests.Session()
        audio = fetch_audio(session, url)
        time.sleep(DELAY)
        with lock:
            cache[url] = audio
            done[0] += 1
            if done[0] % 100 == 0 or done[0] == total:
                pct = done[0] / total * 100
                print(f'  [{done[0]}/{total}] {pct:.0f}%', flush=True)
                save_cache(cache)
        return url, audio

    with ThreadPoolExecutor(max_workers=CONCURRENCY) as ex:
        futures = {ex.submit(worker, u): u for u in to_fetch}
        for fut in as_completed(futures):
            try:
                fut.result()
            except Exception as e:
                print(f'  Error: {e}', file=sys.stderr)

    save_cache(cache)
    return {u: cache.get(u, '') for u in targets}


# ── CSV update ────────────────────────────────────────────────────────────────

def update_csvs(pop_map: dict, audio_map: dict):
    """Rewrite every CSV with correct audio links."""
    total_filled = 0
    for f in sorted(glob.glob(os.path.join(BASE, '**', '*.csv'), recursive=True)):
        with open(f, newline='', encoding='utf-8') as fp:
            rows = list(csv.reader(fp))
        if len(rows) < 2:
            continue

        changed = False
        for i, row in enumerate(rows[1:], start=1):
            if len(row) < 8:
                row += [''] * (8 - len(row))
                rows[i] = row

            word  = row[3].strip().lower()
            ourl  = row[1].strip()
            audio = row[7].strip()

            new_audio = (
                audio            # keep original if present
                or pop_map.get(word, '')            # reuse from popularity
                or audio_map.get(ourl, '')          # scraped
            )

            if new_audio != audio:
                row[7] = new_audio
                changed = True
                total_filled += 1

        if changed:
            with open(f, 'w', newline='', encoding='utf-8') as fp:
                writer = csv.writer(fp)
                writer.writerows(rows)

    print(f'\nUpdated {total_filled} audio links.')


# ── main ──────────────────────────────────────────────────────────────────────

def main():
    print('Building popularity map …')
    pop_map = build_pop_map()
    print(f'  {len(pop_map)} words with known audio.')

    print('Collecting scrape targets …')
    targets = collect_scrape_targets(pop_map)
    print(f'  {len(targets)} unique Oxford URLs to resolve.')

    cache = load_cache()
    print('Scraping Oxford …')
    audio_map = scrape_missing(targets, cache)

    print('Updating CSV files …')
    update_csvs(pop_map, audio_map)
    print('Done.')


if __name__ == '__main__':
    main()
