Phase 5 - History
=================

Status
------
Core implemented.


Goal
----
Preserve season outcomes so the world remembers trophies, statistics, and
career records.


Main Files
----------
- `app/models/trophy.rb`
- `app/models/tournament_finalizer.rb`
- `app/models/manager_season_stat.rb`
- `app/models/club_season_stat.rb`
- `app/models/athlete_season_stat.rb`
- `app/views/careers/show.html.erb`
- `app/views/clubs/show.html.erb`
- `app/views/athletes/show.html.erb`


Implemented
-----------
- Trophy storage.
- Tournament participation outcomes.
- Tournament edition completion when all fixtures are completed.
- Champion assignment from standings.
- Manager season stats.
- Club season stats.
- Athlete season stats.
- Trophy history on career and club pages.
- Manager season history on career page.
- Club season history and top scorers on club page.
- Athlete stats on athlete profiles.


Behavior
--------
Completed seasons are finalized into historical records instead of being
discarded when the next season begins.


Tests
-----
Covered by trophy, tournament-finalizer, manager-season-stat,
club-season-stat, and athlete-season-stat tests.


Deferred
--------
- Top scorer awards.
- Best player, keeper, and young player awards.
- Hall of fame records.
- Promotion and relegation history.
- Rich financial season snapshots.
