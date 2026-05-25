Phase 26 - Import Audit and Data Normalization
==============================================

Status
------
Planned.


Goal
----
Audit the imported Brasfoot world and add cleanup tools before gameplay relies
heavily on imported data.


Planned Scope
-------------
- Add a Brasfoot audit report service.
- Add a readable `bin/rails brasfoot:audit` task.
- Report total imported countries, clubs, athletes, contracts, tournaments,
  editions, participations, fixtures, and assets.
- Report clubs by country and athletes by country.
- Detect clubs without stadiums.
- Detect clubs without crests or shirts.
- Detect athletes without current contracts.
- Detect duplicate club names by country.
- Detect duplicate stadium names by country.
- Detect tournaments without editions.
- Detect editions with too few clubs.
- Detect suspicious fixture counts.
- Detect countries still using fallback `Brasfoot Pack`.
- Improve country/config mappings from audit results.
- Improve tournament naming where Brasfoot config names are too generic.
- Add cleanup helpers for common safe normalizations.


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


Deferred
--------
- Browser-based import dashboard.
- Automated destructive cleanup.
- Perfect real-world validation against external databases.
