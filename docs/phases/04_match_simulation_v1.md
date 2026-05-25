Phase 4 - Match Simulation v1
=============================

Status
------
Implemented at first-playable depth.


Goal
----
Make fixtures playable with a Brasfoot-like match flow: time advances, the
manager can pause, and substitutions/tactical choices can be made.


Main Files
----------
- `app/controllers/fixtures_controller.rb`
- `app/models/match_simulator.rb`
- `app/models/match_state.rb`
- `app/models/match_event.rb`
- `app/models/lineup.rb`
- `app/models/lineup_athlete.rb`
- `app/views/fixtures/show.html.erb`


Implemented
-----------
- Fixture page.
- Deterministic instant simulation.
- Match status and score storage.
- Standings updates from match results.
- Match timeline with goal events.
- Career date advancement to match day and next match.
- Basic athlete match and season stats.
- Lineups and bench selections.
- Live clock in 15-minute advances.
- Pause and resume controls.
- Substitutions.
- Basic formation and mentality controls.


Behavior
--------
The player can enter a fixture, advance match time, pause for decisions, make
substitutions, adjust basic tactics, and complete the match into stored history.


Tests
-----
Covered by fixture controller tests, fixture setup tests, match simulator tests,
match event tests, and fixture model tests.


Deferred
--------
- True minute-by-minute event simulation.
- Tactical settings deeply influencing every simulation outcome.
- Advanced match visualization.
