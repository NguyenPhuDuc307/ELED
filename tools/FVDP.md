# FVDP source comparison

Download page: https://dictionarymid.sourceforge.net/dictionaries/dictsVietnameese.html

```sh
mkdir -p output/fvdp
curl -fL --max-time 120 \
  'https://downloads.sourceforge.net/project/dictionarymid/dictionary%20EngVie/3.0/DictionaryForMIDs_3.0.0_EngVie_109k.zip' \
  -o output/fvdp/fvdp-eng-vie.zip
python3 tools/stage_fvdp.py --archive output/fvdp/fvdp-eng-vie.zip
```

This reads the nested JAR as a ZIP, without running Java or extracting paths.
The separate SQLite DB contains `sources`, `source_entries`, `app_words` and
`comparisons`. All comparison rows start as `needs_review`; neither production
nor application vocabulary is modified. Existing review databases are not
replaced. Give a new `--database` and `--report` path for a new review.

The JSON report contains coverage and known regression checks. The adjacent
CSV is suitable for inspecting current meanings alongside source candidates.
An exact headword/POS match is only a candidate, not semantic verification.
POS markers, example sentences and idiom definitions are kept distinct;
unknown POS labels remain unclassified. Original bodies are retained.

Results for the downloaded archive (SHA-256
`cfb941011db2efc931f6580b0c2e6d7b6e027167d74b3f0b6f28e3d9a46a762e`):

- 104,966 source records;
- 16,385 of ELED's 23,481 headwords match exactly; 7,096 do not;
- the source repeats the problematic leading senses of plane, clock, nurse,
  sweater and popular, and the can/could confusion;
- player leads with the narrower sports sense, rather than the general learner
  meaning. This is a relevance limitation, not a claim that “cầu thủ” is false.

Consequently this archive is not approved as a replacement for the learner DB.
The archive COPYING covers the Java application under GPL v2, while README
refers dictionary copyright to other metadata. Do not assume this alone
establishes permission for republishing the dictionary dataset.

Tests: `python3 -m unittest discover -s tools -p test_stage_fvdp.py`.
