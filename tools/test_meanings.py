import csv, io, json, tarfile, unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class MeaningsTest(unittest.TestCase):
    def test_keys_and_non_translation_fields_unchanged(self):
        backup=Path('/tmp/eled-data-before-meanings.tgz')
        if not backup.exists(): self.skipTest('Original local snapshot is unavailable')
        with tarfile.open(backup) as archive:
            for member in archive.getmembers():
                if not member.name.endswith('.csv') or Path(member.name).name.startswith('._'): continue
                before=list(csv.DictReader(io.StringIO(archive.extractfile(member).read().decode('utf-8-sig'))))
                with (ROOT/member.name).open(encoding='utf-8-sig',newline='') as file: after=list(csv.DictReader(file))
                self.assertEqual(len(before),len(after),member.name)
                for old,new in zip(before,after):
                    self.assertEqual({k:v for k,v in old.items() if k!='translation'},{k:v for k,v in new.items() if k!='translation'},member.name)
    def test_meanings_are_separated_by_part_of_speech(self):
        meanings=json.loads((ROOT/'assets/lexicon/meanings.json').read_text())
        self.assertEqual(meanings['fine']['noun'],['tiền phạt'])
        self.assertEqual(meanings['fine']['verb'],['phạt tiền'])
        self.assertIn('món quà',meanings['present']['noun'])
        self.assertIn('then chốt',meanings['key']['adjective'][0])
        self.assertIn('nhỏ',meanings['minute2']['adjective'][0])
        for word, groups in meanings.items():
            self.assertTrue(groups,word)
            for pos, glosses in groups.items():
                self.assertTrue(pos)
                self.assertTrue(glosses,word)
                self.assertTrue(all(isinstance(g,str) and g.strip() for g in glosses),word)
                self.assertEqual(len(glosses),len(set(glosses)),word)
    def test_common_senses_precede_rare_homographs(self):
        meanings=json.loads((ROOT/'assets/lexicon/meanings.json').read_text())
        reviewed=json.loads((ROOT/'assets/lexicon/reviewed.json').read_text())
        built={r[0].lower():r for r in json.loads((ROOT/'apps/web/public/vocabulary.json').read_text())}
        for word,pos,expected in [('plane','noun','máy bay'),('meal','noun','bữa ăn'),('summer','noun','mùa hè'),('abandon','verb','từ bỏ; bỏ rơi, ruồng bỏ')]:
            self.assertEqual(meanings[word][pos][0],expected)
            self.assertEqual(reviewed[word][pos][0],expected)
            self.assertEqual(dict(built[word][8])[pos][0],expected)
            self.assertIn(expected,built[word][1])
        for word,groups in reviewed.items():
            if word not in built: continue
            senses=dict(built[word][8]) if len(built[word])>8 else {}
            for pos,values in groups.items():
                if pos in senses:self.assertEqual(senses[pos],values,(word,pos))
    def test_built_vocabulary_has_same_keys_and_accurate_ambiguous_meanings(self):
        rows=json.loads((ROOT/'apps/web/public/vocabulary.json').read_text())
        self.assertEqual(len(rows),23481)
        self.assertEqual(len({r[0].lower() for r in rows}),23481)
        byword={r[0].lower():r for r in rows}
        self.assertIn('tiền phạt',byword['fine'][1])
        self.assertIn('món quà',byword['present'][1])
        self.assertEqual(dict(byword['content2'][8])['adjective'][0],'hài lòng, bằng lòng')
if __name__=='__main__': unittest.main()
