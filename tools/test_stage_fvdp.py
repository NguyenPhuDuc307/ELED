import io
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path
from zipfile import ZipFile
from stage_fvdp import parse_body, stage, unmark

class StageFvdpTest(unittest.TestCase):
    def test_formatting_pos_examples_and_idioms_do_not_mix(self):
        result=parse_body('[01* dtừ]\\n- nghĩa một [02ghi chú]\\n[02= English example] Ví dụ Việt\\n[04! an idiom]\\n- nghĩa thành ngữ\\n[01* ngđtừ]\\n- nghĩa động từ\\n[01* unknown]\\n- giữ để kiểm tra')
        self.assertEqual([(s['pos'],s['gloss']) for s in result['senses']], [('noun','nghĩa một ghi chú'),('verb','nghĩa động từ'),(None,'giữ để kiểm tra')])
        self.assertEqual(result['examples'][0]['en'],'English example')
        self.assertEqual(unmark('a [01b [02c]]'),'a b c')

    def test_staging_preserves_app_rows_and_keeps_unmatched_words_without_approving(self):
        with tempfile.TemporaryDirectory() as d:
            d=Path(d);jar=io.BytesIO()
            with ZipFile(jar,'w') as z:
                z.writestr('dictionary/directoryEng1.csv','plane [01/pleɪn/]\t[01* dtừ]\\n- cây tiêu huyền\\n- máy bay\n')
            archive=d/'fvdp.zip'
            with ZipFile(archive,'w') as z:z.writestr('DictionaryForMIDsEngVie.jar',jar.getvalue())
            vocab=[['plane','máy bay','noun','','','',['A1'],[],[['noun',['máy bay']]]],['missing','chưa có','noun','','','',[],[]]]
            input_path=d/'vocabulary.json';input_path.write_text(json.dumps(vocab))
            dbpath=d/'review.sqlite';report=stage(archive,input_path,dbpath,d/'report.json')
            self.assertEqual(json.loads(input_path.read_text()),vocab)
            self.assertEqual(report['headword_coverage'],{'matched_headword':1,'missing_headword':1})
            self.assertTrue(report['regression_checks'][0]['problem_is_first'])
            self.assertEqual(report['automatically_approved'],0)
            self.assertEqual(report['production_changes'],0)
            with sqlite3.connect(dbpath) as db:
                self.assertEqual(db.execute("select review_status from comparisons where word_key='plane'").fetchone()[0],'needs_review')
                self.assertEqual(json.loads(db.execute("select payload_json from app_words where word_key='plane'").fetchone()[0]),vocab[0])
            self.assertTrue((d/'report.csv').exists())
            with self.assertRaises(ValueError):stage(archive,input_path,dbpath,d/'other.json')

if __name__=='__main__':unittest.main()
