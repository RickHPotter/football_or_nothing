Phase 27 - Gameplay Bridge and Frontend Exposure
================================================

Status
------
Implemented at first browsing depth.


Goal
----
Make imported Brasfoot data visible, browsable, and useful in the playable
manager career loop.


Implemented
-----------
- Career-scoped country index and country show screens.
- Career-scoped club index and browsable club show screens.
- Career-scoped tournament index and tournament show screens.
- Top navigation links for countries, clubs, and tournaments.
- Imported club crests on job lists, club lists, and club show pages.
- Global unemployed job market with country filter.
- Club browser job actions for eligible unemployed managers.
- Manager reputation gating restored for club jobs.
- International club jobs remain gated behind high manager reputation.
- Browse-only clubs hide management controls such as training and youth academy.
- Tournament show pages expose current standings and fixtures.


Expected Files
--------------
- `app/controllers/countries_controller.rb`
- `app/controllers/tournaments_controller.rb`
- `app/controllers/clubs_controller.rb`
- `app/controllers/careers_controller.rb`
- `app/views/countries/*`
- `app/views/tournaments/*`
- `app/views/clubs/*`
- `app/views/careers/show.html.erb`


Acceptance
----------
- A manager can browse imported countries, clubs, tournaments, editions,
  fixtures, and squads without using Rails console.
- A manager can take an eligible job at an imported club.
- Imported club assets render in the UI.
- Job eligibility respects manager reputation.
- The career dashboard reflects imported club context.


Tests
-----
Covered by country, club, tournament, career, manager-contract, and manager
eligibility controller/model tests.


Deferred
--------
- Deep financial realism for imported clubs.
- Full multi-country calendar orchestration.
- Advanced search and scouting UI over the full imported database.
- Persisted playable/non-playable flags for imported leagues.
- Competition-specific job-market filters.
