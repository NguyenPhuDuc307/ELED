import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from urllib.error import HTTPError

from scrape_cambridge import AccessBlocked, BASE, PREFIX, Fetcher, ParseError, completed, load_words, main, parse_entry

FIXTURE = Path(__file__).parent / 'fixtures/cambridge-entry.html'

class CambridgeTest(unittest.TestCase):
    def test_senses_pos_homographs_and_example_translations_stay_separate(self):
        result = parse_entry(FIXTURE.read_text(), 'sample', BASE + PREFIX + 'sample')
        self.assertEqual([e['part_of_speech'] for e in result['entries']], ['noun','verb','noun'])
        sense = result['entries'][0]['senses'][0]
        self.assertEqual(sense['translations_vi'], ['nghĩa thứ nhất'])
        self.assertEqual(sense['examples'], [{'en':'Sample example.', 'vi':['Bản dịch của ví dụ.']}])
        self.assertEqual(sense['labels'], ['SPORT'])
        self.assertEqual(result['entries'][0]['pronunciations'][0]['region'], 'uk')
        self.assertEqual(result['entries'][0]['senses'][1]['translations_vi'], ['nghĩa thứ hai'])

    def test_rejects_challenges_wrong_dictionary_and_empty_markup(self):
        with self.assertRaises(AccessBlocked): parse_entry('<title>Just a moment...</title>', 'x', BASE + PREFIX + 'x')
        with self.assertRaises(ParseError): parse_entry(FIXTURE.read_text(), 'sample', BASE + '/dictionary/english/sample')
        with self.assertRaises(ParseError): parse_entry('<html>No entries</html>', 'x', BASE + PREFIX + 'x')

    def test_robots_and_http_blocks_stop_instead_of_retrying(self):
        fetcher = Fetcher()
        with patch.object(fetcher.opener, 'open', side_effect=HTTPError(BASE,403,'Forbidden',{},None)) as request:
            with self.assertRaises(AccessBlocked): fetcher.check_robots()
            self.assertEqual(request.call_count,1)
        with patch.object(fetcher, 'get', return_value=('User-agent: *\nDisallow: /dictionary/\n', BASE + '/robots.txt')):
            with self.assertRaises(AccessBlocked): fetcher.check_robots()
        with patch.object(fetcher, 'get', return_value=('<html>challenge</html>', BASE + '/robots.txt')):
            with self.assertRaises(AccessBlocked): fetcher.check_robots()

    def test_resume_only_completed_records_and_offline_mode(self):
        with tempfile.TemporaryDirectory() as d:
            words = Path(d)/'words.txt'; words.write_text('plane\nPlane\npopular\n')
            self.assertEqual(load_words(words), ['plane','popular'])
            words.write_text('https://example.com\n')
            with self.assertRaises(ValueError): load_words(words)
            self.assertEqual(load_words(words, skip_invalid=True), [])
            out = Path(d)/'out.jsonl'
            with patch('scrape_cambridge.Fetcher.get', side_effect=AssertionError('offline must not fetch')):
                self.assertEqual(main(['--html',str(FIXTURE),'--word','sample','--output',str(out)]),0)
            self.assertEqual(completed(out), {'sample'})
            out.write_text(out.read_text()+json.dumps({'status':'error','word':'retry-me'})+'\n')
            self.assertEqual(completed(out), {'sample'})

if __name__ == '__main__': unittest.main()
