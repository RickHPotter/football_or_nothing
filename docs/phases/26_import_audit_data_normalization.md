Phase 26 - Import Audit and Data Normalization
==============================================

Status
------
Implemented at audit-report depth.


Goal
----
Audit the imported Brasfoot world and add cleanup tools before gameplay relies
heavily on imported data.


Implemented
-----------
- `DataImport::Brasfoot::AuditReport`.
- Readable `bin/rails brasfoot:audit` task.
- Summary counts for imported countries, clubs, athletes, contracts, stadiums,
  tournaments, editions, participations, fixtures, club assets, and fallback
  country clubs.
- Issue buckets for:
  - fallback-country clubs
  - clubs without stadiums
  - clubs without crests
  - clubs without home shirts
  - athletes without current contracts
  - duplicate club names by country
  - duplicate stadium names by country
  - tournaments without editions
  - editions without clubs
  - suspicious fixture counts
- Configurable source, league source, and output limit through environment
  variables.


Expected Files
--------------
- `app/models/data_import/brasfoot/audit_report.rb`
- `lib/tasks/brasfoot.rake`
- `docs/importing_brasfoot.md`
- `test/models/data_import/brasfoot/audit_report_test.rb`


Acceptance
----------
- `bin/rails brasfoot:audit` exits cleanly on imperfect imported data.
- The report is readable in the terminal.
- The report identifies concrete cleanup targets without requiring Rails
  console queries.
- Re-running normalization does not duplicate records.


Tests
-----
Covered by `DataImport::Brasfoot::AuditReportTest`.


Deferred
--------
- Browser-based import dashboard.
- Automated destructive cleanup.
- Perfect real-world validation against external databases.
- Automatic normalization tasks. Country and tournament cleanup should be
  guided by the audit output first.
