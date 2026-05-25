Phase 25 - Brasfoot Pack Import
===============================

Status
------
Implemented at first-playable import depth.


Goal
----
Make a local Brasfoot pack a first-class bootstrap source for real-world-like
clubs, athletes, assets, and league structures.


Main Files
----------
- `app/models/data_import/brasfoot/java_serialization_reader.rb`
- `app/models/data_import/brasfoot/team_file_parser.rb`
- `app/models/data_import/brasfoot/pack_importer.rb`
- `app/models/data_import/brasfoot/club_asset_importer.rb`
- `app/models/data_import/brasfoot/league_config_parser.rb`
- `app/models/data_import/brasfoot/league_membership_planner.rb`
- `app/models/data_import/brasfoot/league_importer.rb`
- `app/models/data_import/brasfoot/team_tournament_probe.rb`
- `lib/tasks/brasfoot.rake`
- `docs/importing_brasfoot.md`


Implemented
-----------
- Java serialization reader support for Brasfoot `.ban`, `.cfg`, and `.ces`
  files.
- Team file parser for clubs, stadium names, managers, players, attributes, and
  raw metadata.
- Idempotent club, stadium, athlete, and athlete-contract import from `.ban`
  files.
- Country inference from known Brasfoot filename suffixes and decoded country
  metadata.
- Stadium relocation and duplicate-name disambiguation for re-imports.
- Active Storage attachments for club crest, mini crest, home shirt, away shirt,
  and third shirt PNGs.
- National `.cfg` and Brazilian state `.ces` config parsing.
- League membership planning from decoded team metadata.
- Domestic tournament, edition, participation, and fixture generation for
  imported league configs.
- Brasfoot config country-code normalization for codes such as `ALE`, `ING`,
  `HOL`, and `EUA`.
- Master rake task that imports teams, assets, and configured leagues.


Rake Tasks
----------
- `bin/rails brasfoot:import`
- `bin/rails brasfoot:file[...]`
- `bin/rails brasfoot:league_config[...]`
- `bin/rails brasfoot:debug_team[...]`
- `bin/rails brasfoot:plan_memberships[...]`
- `bin/rails brasfoot:import_league[...]`
- `bin/rails brasfoot:assets`


Behavior
--------
The master import reads a local Brasfoot pack through `BRASFOOT_PACK_PATH`,
imports all team data, attaches visual assets, then imports all discovered
national and state competition configs unless those phases are skipped with
environment flags.


Tests
-----
Covered by Java serialization reader, club asset importer, and league importer
tests, plus manual runner/rake verification against the local pack.


Deferred
--------
- Complete country-code mapping for every obscure pack code.
- Perfect real-world competition membership.
- Import UI.
- Licensing/distribution workflow for pack data.
- Data quality audit and normalization tooling, planned for Phase 26.
