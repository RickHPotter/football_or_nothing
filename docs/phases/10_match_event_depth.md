Phase 10 - Match Event Depth
============================

Status
------
Implemented at first-playable depth.


Goal
----
Make simulated matches feel less empty by adding non-goal events and storing
their statistical impact.


Main Files
----------
- `app/models/match_event.rb`
- `app/models/match_simulator.rb`
- `app/models/athlete_season_stat.rb`
- `app/views/fixtures/show.html.erb`


Implemented
-----------
- Match event types for major chances, yellow cards, red cards, injuries, and
  substitutions.
- Deterministic non-goal timeline events.
- Goal events and score storage remain deterministic.
- Card and injury totals on athlete season stats.
- Detailed event labels in the match timeline.
- Cards and injuries on athlete stat tables.


Behavior
--------
Match timelines now produce meaningful events beyond goals, and those events
affect season statistics.


Tests
-----
Covered by match simulator, match event, athlete season stat, and fixture tests.


Deferred
--------
- Possession-by-possession simulation.
- Tactical probability modifiers.
- Assists and ratings generated from events.
