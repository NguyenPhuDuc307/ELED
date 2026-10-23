# Cambridge English–Vietnamese importer

Run from the ELED repository root. `uv` installs the script's isolated Python
dependency automatically; it does not modify the application's environment.

```sh
printf 'plane\npopular\nplayer\n' > /tmp/cambridge-words.txt
uv run tools/scrape_cambridge.py --words /tmp/cambridge-words.txt
```

Read the current ELED vocabulary, explicitly skipping malformed source keys:

```sh
uv run tools/scrape_cambridge.py \
  --words apps/web/public/vocabulary.json --skip-invalid --limit 20
```

After checking a sample and confirming permitted access, process the full input:

```sh
uv run tools/scrape_cambridge.py \
  --words apps/web/public/vocabulary.json --skip-invalid --limit 0 --delay 5
```

Requests are sequential, at least three seconds apart (default five seconds),
and respect any larger robots.txt crawl delay/request interval. Running the same
command resumes from successful and 404 records in the output. HTTP 401/403/429,
unavailable/denying robots rules, challenge pages and unexpected HTML stop the
run with exit code 2. There is no proxy rotation, stealth browser or CAPTCHA
bypass. This environment returned 403 for robots.txt during verification, so no
real dictionary entries have been downloaded or live-parser compatibility proven.

Default output: `output/cambridge/entries.jsonl`, one record per requested word.
Raw successful HTML is cached in `output/cambridge/html/`. Output and HTML are
ignored by Git. Each successful record retains:

- source URL, retrieval time, content hash and available credit text;
- separate homograph/POS entries, IPA and audio URL references;
- each English definition linked to its own Vietnamese translations, labels
  and examples; example translations are not treated as headword meanings.

No application vocabulary, learner progress or production service is changed.
The resulting records are staging data, not automatic replacements. Sense-level
matching/review and data-use permission are separate from downloading; Cambridge's
Anh–Việt pages credit PASSWORD / K Dictionaries. Retain provenance and establish
permission for bulk storage and redistribution before incorporating the data.

For a local HTML file you already have, without network access:

```sh
uv run tools/scrape_cambridge.py \
  --html /path/to/entry.html --word plane --output /tmp/plane.jsonl
```

Tests use synthetic HTML, not scraped publisher content:

```sh
uv run --with beautifulsoup4 python -m unittest discover -s tools -p test_scrape_cambridge.py
```
