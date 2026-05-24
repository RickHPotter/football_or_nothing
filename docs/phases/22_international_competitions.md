Phase 22 - International Competitions
=====================================

Status
------
Implemented at first-playable depth.


Goal
----
Expand the world beyond domestic competitions without disrupting the existing
club career loop.


Main Files
----------
- `app/models/international_competition_generator.rb`
- `app/models/manager.rb`
- `app/controllers/careers_controller.rb`
- `app/views/careers/show.html.erb`


Behavior
--------
`InternationalCompetitionGenerator`:
- Creates an international tournament.
- Creates one lightweight national-team-style club per country.
- Marks those teams with `Club#international`.
- Creates basic stadiums and generated squads for international teams.
- Schedules fixtures through the existing league scheduler.
- Is idempotent for the same host/season.

Manager job eligibility:
- International clubs require high manager reputation.
- Existing low-reputation careers remain domestic-first.


UI
--
- Career dashboard shows recent international tournament editions, status, date
  range, and champion.


Tests
-----
Covered by international competition generator tests, manager eligibility
tests, and career dashboard controller coverage.


Deferred
--------
- National squad selection from real club players.
- International breaks.
- Continental qualification.
- Country coefficients and rankings.
- Dedicated tournament detail page.
