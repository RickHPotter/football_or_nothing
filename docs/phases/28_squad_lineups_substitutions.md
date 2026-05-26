Phase 28 - Squad Lineups and Substitutions
==========================================

Status
------
Implemented at first lineup-generation depth.


Goal
----
Make match squads football-realistic before kickoff and prevent substitution
rules from treating previously substituted players as unused bench options.


Main Files
----------
- `app/models/lineup_template.rb`
- `app/models/lineup_builder.rb`
- `app/models/fixture.rb`
- `app/controllers/fixtures_controller.rb`
- `test/models/fixture_match_setup_test.rb`
- `test/controllers/fixtures_controller_test.rb`


Implemented
-----------
- Formation templates for `4-4-2`, `4-3-3`, and `4-2-3-1`.
- Each formation defines exactly 11 starter slots.
- Each formation defines one goalkeeper starter slot.
- Automatic lineup generation now fills slots by preferred and fallback
  positions instead of taking the first athletes ordered by position.
- Starting lineups avoid multiple goalkeepers when outfield players are
  available.
- Bench selection is balanced by role group and avoids loading the bench with
  extra goalkeepers.
- Injured and suspended athletes are still avoided where possible.
- Fixture setup remains idempotent.
- Substituted-off players cannot re-enter as unused bench players.
- Invalid substitution attempts redirect with a clear alert.


Rules
-----
- The builder chooses by position fit first, then ability, condition, and
  reputation.
- The bench target is seven players.
- The bench tries to include goalkeeper, defensive, midfield, and attacking
  cover.
- If a squad is incomplete, the builder creates the best valid partial lineup it
  can instead of crashing.


Tests
-----
Covered by fixture setup and fixture controller tests:
- formation templates have 11 slots and one goalkeeper
- a squad with many goalkeepers starts only one
- the bench does not fill with extra goalkeepers
- injured players are avoided where possible
- setup does not duplicate lineups
- substituted-off players cannot re-enter


Deferred
--------
- Persisting explicit slot names on `LineupAthlete`.
- Manager-facing pre-match lineup editor.
- Formation-specific visual layout.
- AI substitution planner during live clock advancement.
- Position-fit penalties in match strength calculation.
- Tactical role depth beyond the current standard role.
