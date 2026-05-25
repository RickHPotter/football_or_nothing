Importing OpenFootball Data
===========================

Overview
--------
OpenFootball import is explicit. Nothing is imported automatically when the app
boots.

The importer reads OpenFootball-style JSON payloads and creates:
- country
- tournament
- tournament edition
- clubs
- fallback stadiums
- tournament participations
- fixtures
- completed scores when a payload includes `score.ft`


Master Import
-------------
Run the curated master import:

```bash
bin/rails openfootball:master
```

Default dataset groups:
- `football_json`
- `worldcup_json`
- `england`
- `champions_league`
- `south_america`

The task is tolerant by default. Missing optional URLs are skipped with a warning.
Use strict mode to fail on the first problem:

```bash
OPENFOOTBALL_STRICT=true bin/rails openfootball:master
```

Choose seasons and calendar years:

```bash
OPENFOOTBALL_SEASONS=2023-24,2022-23 OPENFOOTBALL_YEARS=2024,2022 bin/rails openfootball:master
```

Choose dataset groups:

```bash
OPENFOOTBALL_DATASETS=football_json,worldcup_json bin/rails openfootball:master
```


Single URL Import
-----------------
```bash
bin/rails 'openfootball:url[https://raw.githubusercontent.com/openfootball/football.json/master/2023-24/en.1.json,England,ENG,openfootball:england,Premier League,EPL,2023]'
```


Local File Import
-----------------
```bash
bin/rails 'openfootball:file[tmp/openfootball/england/2023-24/en.1.json,England,ENG,openfootball:england,Premier League,EPL,2023]'
```


Notes
-----
- Imports are idempotent by source and external identity.
- Countries are reused by country code across related dataset source keys. This
  means `football_json:england...` and `england:...` both resolve to the same
  England record instead of creating duplicates.
- Clubs are reused by country/name across related dataset source keys.
- The master task deduplicates exact duplicate URLs before importing.
- `football.json` and `worldcup.json` are JSON-first and are the safest sources.
- Some OpenFootball repositories, such as `champions-league`,
  `south-america`, and `internationals`, are primarily Football.TXT sources.
  The master task tries common generated JSON mirror paths and skips missing
  URLs unless strict mode is enabled.
- Football.TXT parsing is not implemented yet.
