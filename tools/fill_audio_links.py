#!/usr/bin/env python3
"""
Fill missing audio_link column in all vocabulary CSVs.
Uses Oxford Learner's Dictionary audio URL pattern:
  /media/english/uk_pron/{l1}/{l3}/{l5}/{word}__gb_1.mp3
"""

import csv
import os
import glob

BASE = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
AUDIO_BASE = 'https://www.oxfordlearnersdictionaries.com/media/english/uk_pron'


def build_audio_url(word: str) -> str:
    w = word.lower().strip()
    if not w:
        return ''
    l1 = w[0]
    l3 = w[:3].ljust(3, '_')
    l5 = w[:5].ljust(5, '_')
    return f'{AUDIO_BASE}/{l1}/{l3}/{l5}/{w}__gb_1.mp3'


def process_csv(path: str) -> int:
    with open(path, newline='', encoding='utf-8') as f:
        rows = list(csv.reader(f))

    if len(rows) < 2:
        return 0

    filled = 0
    for i, row in enumerate(rows[1:], start=1):
        if len(row) < 8:
            # pad to 8 columns
            row += [''] * (8 - len(row))
            rows[i] = row
        if not row[7].strip() and len(row) > 3 and row[3].strip():
            row[7] = build_audio_url(row[3])
            filled += 1

    if filled > 0:
        with open(path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerows(rows)

    return filled


def main():
    csv_files = glob.glob(os.path.join(BASE, '**', '*.csv'), recursive=True)
    total_filled = 0
    for path in sorted(csv_files):
        n = process_csv(path)
        if n:
            rel = os.path.relpath(path, BASE)
            print(f'  {rel}: +{n} audio links')
            total_filled += n

    print(f'\nDone — filled {total_filled} audio links across {len(csv_files)} files.')


if __name__ == '__main__':
    main()
