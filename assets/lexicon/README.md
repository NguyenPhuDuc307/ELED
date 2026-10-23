# ELED bilingual meaning corrections

`meanings.json` contains exact-headword and POS-matched Vietnamese Wiktionary
senses extracted through Kaikki/Wiktextract. Source dump: 2026-09-01;
extraction: 2026-10-03. `reviewed.json` contains ELED's curated overrides for
common ambiguous words and explicitly disambiguated Oxford headwords.
These are not a claim of human editorial review of every entry.

Source: https://kaikki.org/viwiktionary/
Download: https://kaikki.org/dictionary/downloads/vi/vi-extract.jsonl.gz
SHA-256: 566a1b6b941d5ec792ce5f79f1830250076a5d9d517c1f3d1aa04dd4dc02482d
Original pages/history: https://vi.wiktionary.org/wiki/<headword>
License of extracted and modified meanings: CC BY-SA 4.0.
https://creativecommons.org/licenses/by-sa/4.0/
Attribution: Vietnamese Wiktionary contributors; Kaikki.org / Wiktextract;
ELED modifications. Application code retains its separate license.

Rebuild with `python3 tools/rebuild_meanings.py /path/to/vi-extract.jsonl.gz`.
Review `changes.json` and `unmatched.json` before running with `--apply`.
Only the translation column in existing CSV files is changed; IDs, headwords,
levels, POS, IPA, audio and URLs are preserved. Unmatched POS rows are retained
verbatim. Never infer a different POS merely to increase coverage. The raw
extract contains missing glosses and extraction/POS errors, so exact matching
alone does not guarantee editorial accuracy. Curated overrides take precedence.

The browser build reads structured senses from this directory and includes
old meanings only for unmatched POS. Games use one POS and its corresponding
meaning per card; lessons show grouped senses. The API seed deploy updates
PostgreSQL without changing profile data or word keys. `audit.json` records
coverage; `changes.json` preserves before/after row changes from the original
CSV snapshot for this update. Source/credit details and downloadable processed
meanings are exposed at `/data-sources.html`.

## Basic learner meanings (23 October 2026)

The primary meanings for 1,678 valid A1/A2 headwords have been checked for
learner relevance. `reviewed.json` now also covers every part of speech emitted
for these words. Misleading homographs and obsolete or specialist lead senses
have been replaced with everyday meanings. Previously uncurated secondary
Wiktionary glosses are not presented as reviewed learner meanings for this set;
reviewed common alternatives are retained. This is a review of primary learner
meanings, not a certification of every specialist word in the 23,481-word pool.

`core-review.json` records the scope, before/after meanings and two malformed
source headwords discovered during the pass. Their identifiers are retained in
this update so existing learning records are not silently reassigned. They are
not included in the 1,678 valid English headwords. Word IDs, levels, IPA, audio,
links and user progress are unchanged. Curated meanings always override raw
extraction during both data preparation and lexicon rebuilding.

The quality tests require all emitted parts of speech of the basic set to use
the curated layer and include regressions for common homograph failures such
as could/can, nurse, clock, elephant, player and popular.
