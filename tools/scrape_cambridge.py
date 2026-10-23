#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["beautifulsoup4>=4.12,<5"]
# ///
"""Cambridge English–Vietnamese importer. Outputs staged JSONL, never edits app data.
Run: uv run tools/scrape_cambridge.py --help
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urljoin, urlparse
from urllib.request import Request, build_opener, HTTPRedirectHandler
from urllib.robotparser import RobotFileParser

from bs4 import BeautifulSoup

BASE = 'https://dictionary.cambridge.org'
PREFIX = '/dictionary/english-vietnamese/'
AGENT = 'ELEDVocabularyImporter/1.0'
MAX_BYTES = 5 * 1024 * 1024


class AccessBlocked(RuntimeError):
    pass


class ParseError(ValueError):
    pass


def safe_url(url: str) -> bool:
    p = urlparse(url)
    return p.scheme == 'https' and p.netloc == 'dictionary.cambridge.org'


class CambridgeRedirects(HTTPRedirectHandler):
    def __init__(self, before_request):
        self.before_request = before_request

    def redirect_request(self, req, fp, code, msg, headers, newurl):
        if not safe_url(newurl):
            raise AccessBlocked('Redirect ra ngoài HTTPS dictionary.cambridge.org; đã dừng')
        self.before_request(newurl)
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def text(node) -> str:
    return ' '.join(node.stripped_strings) if node else ''


def unique(values):
    return list(dict.fromkeys(v for v in values if v))


def parse_entry(html: str, word: str, source_url: str) -> dict:
    if not safe_url(source_url) or not urlparse(source_url).path.startswith(PREFIX):
        raise ParseError('Không phải mục từ English–Vietnamese')
    soup = BeautifulSoup(html, 'html.parser')
    title = text(soup.title).lower()
    if any(s in title for s in ['just a moment', 'access denied', 'attention required']) or soup.select_one('#challenge-form, #cf-challenge-running'):
        raise AccessBlocked('Trang xác minh Cloudflare/CAPTCHA; đã dừng')
    entries = []
    # Keep homographs, POS groups, sense definitions and their own examples separate.
    for index, entry in enumerate(soup.select('.entry-body__el')):
        header = entry.select_one('.pos-header')
        headword = text(header.select_one('.headword, .hw, .dhw')) if header else ''
        pos = text(header.select_one('.pos, .dpos')) if header else ''
        if not headword or not pos:
            continue
        pronunciation = []
        for block in (header.select('.uk, .us') or [header]):
            region = 'uk' if 'uk' in block.get('class', []) else 'us' if 'us' in block.get('class', []) else None
            ipa = unique(text(n) for n in block.select('.ipa'))
            audio = unique(urljoin(BASE, n.get('src', '')) for n in block.select('audio source[src]'))
            if ipa or audio:
                pronunciation.append({'region': region, 'ipa': ipa, 'audio_urls': audio})
        senses = []
        for n, definition_block in enumerate(entry.select('.def-block')):
            definition_node = definition_block.select_one('.def, .ddef_d')
            definition = text(definition_node)
            if not definition:
                continue
            # Example translations must never become standalone headword meanings.
            translations = unique(text(t) for t in definition_block.select('.trans')
                                  if t.find_parent(class_='examp') is None)
            if not translations:
                continue
            examples = []
            for ex in definition_block.select('.examp'):
                en = text(ex.select_one('.eg, .deg'))
                vi = unique(text(t) for t in ex.select('.trans'))
                if en:
                    examples.append({'en': en, 'vi': vi})
            labels = unique(text(x) for x in definition_block.select('.def-info, .usage, .domain, .register, .gram'))
            parent = definition_block.find_parent(class_='sense-block')
            if parent:
                labels = unique(labels + [text(x) for x in parent.select('.sense-title .guideword, .sense-title .usage, .sense-title .domain')])
            senses.append({'source_id': definition_block.get('id') or f'entry-{index + 1}-sense-{n + 1}',
                           'definition_en': definition, 'translations_vi': translations,
                           'labels': labels, 'examples': examples})
        if senses:
            entries.append({'headword': headword, 'part_of_speech': pos,
                            'pronunciations': pronunciation, 'senses': senses})
    if not entries:
        raise ParseError('Không tìm thấy nghĩa Anh–Việt; có thể HTML đã đổi hoặc trang bị chặn. Không dùng nội dung trang làm nghĩa.')
    credits = unique(text(x) for x in soup.select('.credit, .dcredit'))
    return {'schema_version': 1, 'status': 'ok', 'word': word, 'source': 'Cambridge English–Vietnamese',
            'source_url': source_url, 'fetched_at': datetime.now(timezone.utc).isoformat(),
            'content_sha256': hashlib.sha256(html.encode()).hexdigest(),
            'credits': credits, 'entries': entries}


class Fetcher:
    def __init__(self, delay=5.0, timeout=25.0):
        self.delay, self.timeout, self.last = delay, timeout, None
        self.robots = None
        self.opener = build_opener(CambridgeRedirects(self.before_request))

    def before_request(self, url: str):
        if not safe_url(url):
            raise AccessBlocked('URL không thuộc Cambridge')
        if self.robots is not None and not self.robots.can_fetch(AGENT, url):
            raise AccessBlocked(f'robots.txt không cho phép truy cập: {url}')
        if self.last is not None:
            time.sleep(max(0, self.delay - (time.monotonic() - self.last)))
        self.last = time.monotonic()

    def get(self, url: str):
        self.before_request(url)
        try:
            req = Request(url, headers={'User-Agent': AGENT, 'Accept': 'text/html,text/plain;q=0.9'})
            with self.opener.open(req, timeout=self.timeout) as response:
                body = response.read(MAX_BYTES + 1)
                if len(body) > MAX_BYTES:
                    raise ParseError('Trang vượt giới hạn 5 MB')
                return body.decode(response.headers.get_content_charset() or 'utf-8', errors='replace'), response.url
        except HTTPError as e:
            if e.code in (401, 403, 429):
                raise AccessBlocked(f'HTTP {e.code}; dừng để không gửi thêm yêu cầu. Không có cơ chế vượt chặn.') from e
            raise

    def check_robots(self):
        # Fail closed when robots cannot be fetched; a 403 is not permission to crawl.
        try:
            body, _ = self.get(BASE + '/robots.txt')
        except (HTTPError, URLError, TimeoutError) as e:
            raise AccessBlocked(f'Không đọc được robots.txt: {e}') from e
        if '<html' in body.lower() or '<!doctype' in body.lower():
            raise AccessBlocked('robots.txt trả HTML/xác minh thay vì quy tắc crawler')
        self.robots = RobotFileParser()
        self.robots.parse(body.splitlines())
        if not self.robots.can_fetch(AGENT, BASE + PREFIX + 'plane'):
            raise AccessBlocked('robots.txt không cho phép crawler này lấy mục từ')
        crawl_delay = self.robots.crawl_delay(AGENT)
        rate = self.robots.request_rate(AGENT)
        self.delay = max(self.delay, float(crawl_delay or 0), rate.seconds / rate.requests if rate and rate.requests else 0)


def load_words(path: Path, skip_invalid=False):
    if path.suffix.lower() == '.json':
        values = json.loads(path.read_text())
        if not isinstance(values, list):
            raise ValueError('JSON phải là mảng từ, các hàng vocabulary.json hoặc object có trường word')
        words = [v if isinstance(v, str) else v[0] if isinstance(v, list) and v else v.get('word', '') if isinstance(v, dict) else '' for v in values]
    else:
        words = path.read_text().splitlines()
    result, seen = [], set()
    for value in words:
        if not isinstance(value, str):
            raise ValueError('Mục từ phải là chuỗi')
        word = value.strip()
        if not word or word.startswith('#'):
            continue
        if not re.fullmatch(r"[A-Za-z][A-Za-z0-9 '\-]*", word):
            if skip_invalid:
                print(f'Bỏ qua mục từ hỏng: {word!r}', file=sys.stderr)
                continue
            raise ValueError(f'Mục từ không hợp lệ: {word!r}; hãy sửa danh sách đầu vào hoặc dùng --skip-invalid')
        if word.lower() not in seen:
            result.append(word)
            seen.add(word.lower())
    return result


def completed(path: Path):
    done = set()
    if path.exists():
        with path.open() as stream:
            for line in stream:
                try:
                    row = json.loads(line)
                    if row.get('status') in ('ok', 'not_found'):
                        done.add(row['word'].lower())
                except (ValueError, KeyError):
                    raise ValueError(f'JSONL bị hỏng: {path}; khôi phục trước khi chạy tiếp')
    return done


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument('--words', type=Path, help='TXT mỗi dòng một từ, hoặc vocabulary JSON')
    source.add_argument('--html', type=Path, help='Chỉ phân tích một file HTML cục bộ, không gọi mạng')
    parser.add_argument('--skip-invalid', action='store_true', help='Bỏ qua và báo các khóa hỏng trong danh sách đầu vào')
    parser.add_argument('--word', help='Từ tương ứng khi dùng --html')
    parser.add_argument('--output', type=Path, default=Path('output/cambridge/entries.jsonl'))
    parser.add_argument('--cache-dir', type=Path, default=Path('output/cambridge/html'))
    parser.add_argument('--limit', type=int, default=20, help='Số từ chưa xử lý trong lượt này; 0 = tất cả')
    parser.add_argument('--delay', type=float, default=5, help='Khoảng nghỉ giữa request, tối thiểu 3 giây')
    args = parser.parse_args(argv)
    if args.limit < 0 or args.delay < 3:
        parser.error('--limit phải >= 0; --delay phải >= 3')
    if args.html and not args.word:
        parser.error('--html cần --word')
    try:
        if args.html:
            result = parse_entry(args.html.read_text(), args.word, BASE + PREFIX + quote(args.word.lower(), safe=''))
            args.output.parent.mkdir(parents=True, exist_ok=True)
            with args.output.open('a') as f:
                f.write(json.dumps(result, ensure_ascii=False) + '\n')
            print(f'Đã phân tích {args.word}: {args.output}')
            return 0
        words = load_words(args.words, args.skip_invalid)
        done = completed(args.output)
        pending = [w for w in words if w.lower() not in done]
        if args.limit:
            pending = pending[:args.limit]
        if not pending:
            print('Không còn từ cần lấy trong danh sách.')
            return 0
        fetcher = Fetcher(args.delay)
        fetcher.check_robots()
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.cache_dir.mkdir(parents=True, exist_ok=True)
        with args.output.open('a') as output:
            for i, word in enumerate(pending, 1):
                url = BASE + PREFIX + quote(word.lower(), safe='')
                try:
                    html, final_url = fetcher.get(url)
                    result = parse_entry(html, word, final_url)
                    name = hashlib.sha256(url.encode()).hexdigest() + '.html'
                    (args.cache_dir / name).write_text(html)
                except HTTPError as e:
                    if e.code != 404:
                        raise
                    result = {'status': 'not_found', 'word': word, 'source_url': url}
                output.write(json.dumps(result, ensure_ascii=False) + '\n')
                output.flush()
                print(f'[{i}/{len(pending)}] {word}: {result["status"]}', flush=True)
        return 0
    except (AccessBlocked, ParseError, HTTPError, URLError, TimeoutError, ValueError, OSError) as e:
        print(f'Dừng: {e}', file=sys.stderr)
        return 2


if __name__ == '__main__':
    raise SystemExit(main())
