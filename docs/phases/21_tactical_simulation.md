Phase 21 - Tactical Simulation
==============================

Status
------
Implemented at first-playable depth.


Goal
----
Make tactics, player condition, cards, injuries, and substitutions matter in
match outcomes.


Main Files
----------
- `app/models/match_strength_calculator.rb`
- `app/models/match_stat.rb`
- `app/models/match_simulator.rb`
- `app/controllers/fixtures_controller.rb`
- `app/views/fixtures/show.html.erb`


Data Model
----------
`MatchStat`
- Belongs to fixture and club.
- Stores possession, shots, shots on target, fouls, yellow cards, and red
  cards.
- Has one record per fixture/club.


Behavior
--------
`MatchStrengthCalculator` computes team strength from:
- lineup starters
- player attributes
- club reputation
- formation mentality
- squad condition
- red cards
- injuries
- substitutions

`MatchSimulator` now:
- creates texture events before scoring so cards and injuries can affect team
  strength,
- scores from attack strength against defensive strength,
- writes match stats for both clubs,
- keeps existing standings, athlete stats, news, and tournament finalization
  behavior.


UI
--
- Fixture page shows a match stats table after stats exist.


Tests
-----
Covered by match strength calculator tests, match simulator tests, and fixture
controller tests.


Deferred
--------
- True possession engine.
- Tactical role familiarity.
- Advanced substitution AI.
- Set pieces.
