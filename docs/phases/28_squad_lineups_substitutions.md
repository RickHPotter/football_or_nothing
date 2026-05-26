Phase 28 - Squad Lineups and Substitutions
==========================================

Status
------
In progress. Core lineup generation, pre-match controls, substitution guards,
slot persistence, manual swaps, simulation position-fit penalties, and tactical
role effects are implemented.


Goal
----
Make match squads football-realistic before kickoff and prevent substitution
rules from treating previously substituted players as unused bench options.


Main Files
----------
- `app/models/lineup_template.rb`
- `app/models/lineup_builder.rb`
- `app/models/lineup_swapper.rb`
- `app/models/match_strength_calculator.rb`
- `app/models/fixture.rb`
- `app/controllers/fixtures_controller.rb`
- `test/models/fixture_match_setup_test.rb`
- `test/models/lineup_swapper_test.rb`
- `test/models/match_strength_calculator_test.rb`
- `test/controllers/fixtures_controller_test.rb`
- `test/controllers/fixture_lineup_controls_test.rb`


Completed Slices
----------------
- Slice 1: realistic generated lineups and balanced benches.
- Slice 2: fixture lineup controls for formation selection, regeneration, and
  corrected substitution eligibility.
- Slice 3: persisted lineup slot keys for formation-aware UI and future pitch
  layout work.
- Slice 4: manual pre-kickoff lineup swaps that preserve formation slots.
- Slice 5: position-fit penalties in match strength calculation.
- Slice 6: tactical role controls and tactical role strength modifiers.


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
- Manager tactics use supported formation choices instead of free text.
- Pre-kickoff formation changes rebuild the selected lineup.
- Pre-kickoff lineup regeneration is available from the fixture screen.
- Lineup athletes persist formation slot keys such as `rb`, `lcb`, and `st`.
- Fixture lineups show the generated slot key beside each selected athlete.
- Managers can manually swap selected lineup athletes before kickoff.
- Manual swaps preserve the selected formation slot instead of changing the
  formation.
- Match strength now penalizes athletes used outside their natural position.
- Goalkeeper/outfield mismatches receive the strongest position-fit penalty.
- Adjacent role coverage receives only a light penalty.
- Fixture lineups display each athlete's tactical role.
- Managers can change selected athlete tactical roles before kickoff.
- Tactical roles modify match strength: `attack` improves attack while reducing
  defense, `defend` improves defense while reducing attack, and `support`
  lightly improves control.
- Substituted-off players cannot re-enter as unused bench players.
- Substituted-on players remain eligible to be substituted off later.
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
- substituted-on players can be substituted off
- pre-kickoff lineup regeneration works and is blocked after kickoff
- generated starters keep formation slot keys and bench players keep substitute
  slot keys
- manual lineup swaps move players between slots before kickoff
- manual lineup swaps are blocked after kickoff
- awkward position usage lowers attack, defense, and control strength
- tactical role changes are allowed before kickoff and blocked after kickoff
- invalid tactical roles are rejected
- tactical roles influence attack and defense strength


Deferred
--------
- Formation-specific visual layout.
- AI substitution planner during live clock advancement.
