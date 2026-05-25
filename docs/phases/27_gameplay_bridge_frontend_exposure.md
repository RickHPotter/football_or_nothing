Phase 27 - Gameplay Bridge and Frontend Exposure
================================================

Status
------
Planned.


Goal
----
Make imported Brasfoot data visible, browsable, and useful in the playable
manager career loop.


Planned Scope
-------------
- Mark imported leagues as playable or non-playable.
- Decide first playable imported season defaults.
- Connect imported clubs to job generation.
- Use manager reputation to gate imported club jobs.
- Keep international jobs locked behind high reputation.
- Add country browsing screens.
- Add club index and richer club show screens.
- Add tournament and tournament-edition browsing.
- Show imported fixtures and standings.
- Show imported club assets in relevant screens.
- Add job-market filters for country, competition, reputation, and playable
  status.
- Keep the interface dense, readable, and Brasfoot-like.


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


Deferred
--------
- Deep financial realism for imported clubs.
- Full multi-country calendar orchestration.
- Advanced search and scouting UI over the full imported database.
