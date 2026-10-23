import io
import json
import unittest
from unittest.mock import patch
from urllib.error import HTTPError
from urllib.parse import parse_qs, urlparse
import google_translate_vocabulary as google


def response(translation):
    return io.BytesIO(json.dumps([[[translation, None]]]).encode())


class GoogleTranslationTest(unittest.TestCase):
    def test_lost_batch_alignment_falls_back_to_individual_words(self):
        with patch.object(google.urllib.request, 'urlopen', side_effect=[
            response('máy bay và người chơi'), response('máy bay'), response('người chơi')
        ]) as provider:
            self.assertEqual(google.translate(['plane', 'player']), {
                'plane': 'máy bay', 'player': 'người chơi'
            })
            self.assertEqual(provider.call_count, 3)

    def test_homograph_suffix_is_not_sent_as_part_of_the_english_word(self):
        with patch.object(google.urllib.request, 'urlopen', return_value=response('nhỏ')) as provider:
            self.assertEqual(google.translate(['minute2']), {'minute2': 'nhỏ'})
            query=parse_qs(urlparse(provider.call_args.args[0].full_url).query)
            self.assertEqual(query['q'], ['minute'])
            self.assertEqual(query['sl'], ['en'])
            self.assertEqual(query['tl'], ['vi'])

    def test_rate_limit_stops_without_retrying(self):
        failure=HTTPError('https://translate.googleapis.com', 429, 'rate limited', {}, None)
        with patch.object(google.urllib.request, 'urlopen', side_effect=failure) as provider:
            with self.assertRaises(HTTPError):
                google.translate(['plane'])
            self.assertEqual(provider.call_count, 1)

    def test_empty_translation_is_rejected(self):
        with patch.object(google.urllib.request, 'urlopen', return_value=response('')):
            with self.assertRaises(ValueError):
                google.translate(['plane'])

if __name__ == '__main__':
    unittest.main()
