Phase 23 - Data Import Foundation
=================================

Status
------
Implemented at first-playable depth.


Goal
----
Prepare the domain for real-world data imports without corrupting generated
careers or duplicating records.


Main Files
----------
- `app/models/data_import_run.rb`
- `app/models/data_import/base_importer.rb`
- `app/models/data_import/countries_importer.rb`
- `app/models/data_import/clubs_importer.rb`
- `app/models/data_import/athletes_importer.rb`
- `app/models/data_import/contracts_importer.rb`


Data Model
----------
`DataImportRun`
- Tracks source, status, processed record count, notes, start time, and finish
  time.

External identity fields were added to:
- countries
- clubs
- athletes
- athlete contracts

Each uses:
- `external_source`
- `external_id`

The database enforces unique external identity pairs when both fields are
present.


Behavior
--------
Importers are idempotent by `external_source` and `external_id`.

Implemented importers:
- countries
- clubs
- athletes
- contracts

Generated data can continue to exist without external identity fields.


Tests
-----
Covered by importer tests for idempotency and country -> club -> athlete ->
contract relationship mapping.


Deferred
--------
- Import UI.
- CSV/JSON file adapters.
- Automated scraping.
- Licensing checks.
- Conflict-resolution UI.
- Import rollback tooling.
