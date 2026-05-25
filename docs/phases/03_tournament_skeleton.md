Phase 3 - Tournament Skeleton
=============================

Status
------
Implemented for generated domestic leagues.


Goal
----
Create the minimum competition model needed for clubs to play a season and
produce standings.


Main Files
----------
- `app/models/tournament.rb`
- `app/models/tournament_edition.rb`
- `app/models/tournament_participation.rb`
- `app/models/fixture.rb`
- `app/services/league_scheduler.rb`
- `test/services/league_scheduler_test.rb`


Implemented
-----------
- Domestic tournament records.
- Tournament editions by season year.
- Club registration through tournament participations.
- Simple league fixture generation.
- Standings fields on participations.
- Champion assignment support used by later finalization.


Behavior
--------
The generated world receives a domestic league edition, participating clubs,
and fixtures. Match results update the standings stored on tournament
participations.


Tests
-----
Covered by tournament, tournament-edition, tournament-participation, fixture,
and league-scheduler tests.


Deferred
--------
- Cups and knockout formats.
- Promotion and relegation.
- Multi-country calendars.
- Complex scheduling constraints.
