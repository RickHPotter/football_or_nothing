Phase 13 - Squad Availability
=============================

Status
------
Implemented at first-playable depth.


Goal
----
Make injuries and suspensions affect future team selection.


Main Files
----------
- `app/models/athlete.rb`
- `app/models/match_simulator.rb`
- `app/models/lineup.rb`
- `app/models/lineup_athlete.rb`
- `app/views/athletes/show.html.erb`


Implemented
-----------
- Athlete injury and suspension dates.
- Injured athletes from match injury events.
- Suspended athletes from red-card events.
- Condition reduction when injury events are applied.
- Unavailable athletes excluded from generated fixture lineups where possible.
- Athlete availability dates shown on athlete profiles.


Behavior
--------
Squad selection now reacts to match consequences. Injured and suspended players
cannot simply be reused as if nothing happened.


Tests
-----
Covered by athlete availability, fixture setup, match simulator, and athlete
controller tests.


Deferred
--------
- Injury severity and medical recovery model.
- Suspensions by competition.
- Automatic return-to-active status after injury dates pass.
- Squad registration limits.
- Player condition impact on event probabilities.
