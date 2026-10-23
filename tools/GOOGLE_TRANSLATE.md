# Google Translate vocabulary refresh

The production web vocabulary lives in PostgreSQL (`eled_vocabulary`). Its seed
is compiled from `assets/data/**/*.csv` by `apps/web/scripts/prepare-data.mjs`.
Firebase Auth provides login; the legacy mobile app still uses Firestore for
account progress. `tools/upload_vocabulary.py` is an old Storage upload path,
not the active production web data source.

Run from the repository root:

```sh
python3 tools/google_translate_vocabulary.py
python3 tools/google_translate_vocabulary.py --apply
npm run data --prefix apps/web
python3 -m unittest discover -s tools -p 'test_meanings.py'
```

The script uses the same unauthenticated Google Translate endpoint as the
existing ELED translation service. It translates English headwords to Vietnamese,
with up to three requests concurrently and 50 headwords per request. Checkpoints
are written atomically under ignored `output/google/`; reruns reuse completed
translations. A provider error stops the run without applying partial data.
Newline alignment is checked, with individual requests if a batch loses alignment.
No rate-limit or access-block bypass is used.

`--apply` refuses an incomplete vocabulary and updates only CSV translation
fields, then writes `assets/lexicon/google-translations.json`. Builds prioritize
that applied snapshot over the old Wiktionary senses. Google headword translations
have no POS-specific sense analysis; old dictionary senses are deliberately not
attached to these words. Existing Oxford English definitions and their on-demand
translation remain separate.

Numeric homograph suffixes (`close1`, `minute2`) are omitted from translation
requests while their stored keys remain unchanged. One malformed source record
whose headword is an audio URL is excluded; its identifier is retained to avoid
reassigning existing learning records. Machine translations are not a reviewed
bilingual dictionary, particularly for polysemous words and specialist terms.

The old Wiktionary files and attribution remain in `assets/lexicon/` for history;
their CC BY-SA license does not describe the Google-generated snapshot.
Before production deployment, back up the current seed and vocabulary table,
compare every non-translation field, and deploy only the seed and source metadata.
Restart the API to refresh its in-memory snapshot. User profile tables are untouched.
