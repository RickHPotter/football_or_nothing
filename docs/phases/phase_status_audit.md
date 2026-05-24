Phase Status Audit
==================

Purpose
-------
This document separates implemented first-playable behavior from deferred depth
so the next phase can be chosen deliberately.


Summary
-------
Phases 1 through 20 are implemented enough to support the current first
playable loop.

There are no blocking leftovers from phases 1 through 20 that must be completed
before starting Phase 21.

There are, however, many intentional deferrals. These are not bugs by
themselves; they are future depth.


Implemented First-Playable Loop
-------------------------------
- Authentication and manager career.
- Generated fictional world.
- Club dashboard and job selection.
- Domestic league scheduling and standings.
- Match simulation with lineups, substitutions, events, injuries, cards, and
  stats.
- History through trophies and season stats.
- Transfers, offers, transfer windows, loans, and contract expiry.
- RPG progression.
- Squad availability.
- AI squad movement.
- Training.
- Scouting.
- Staff.
- Youth academy.
- News feed.


Not Blocking Before Phase 21
----------------------------
These deferred items can wait until their dedicated future expansion:

- Loan recalls and buy options.
- AI loans and bidding wars.
- Player preferences and agents.
- Detailed medical model.
- Individual training.
- Facilities.
- Scouting costs.
- Staff personalities and poaching.
- Youth competitions.
- Press conferences and media reaction.
- Promotion/relegation.
- Data import.
- UI component extraction.


Worth Considering Before Phase 21
---------------------------------
These are not blockers, but they are close enough to tactical simulation that
they may affect Phase 21 design:

- Player condition currently changes, but it does not strongly influence match
  outcomes yet.
- Tactical roles exist in lineups, but role familiarity and advanced tactical
  effects are not modeled.
- Cards and injuries are stored as events, but team strength does not yet
  react dynamically after a red card or injury.
- Match stats are still event-derived rather than possession/shot-model based.


Recommended Next Step
---------------------
Proceed to Phase 21 - Tactical Simulation.

Phase 21 should focus on making existing data matter in match outcomes:
- formation
- mentality
- position fit
- player attributes
- condition
- red cards
- injuries
- substitutions

The most useful first implementation is likely:
1. `MatchStrengthCalculator`
2. `MatchStat`
3. A refactor of `MatchSimulator` to use team strength snapshots and write match
   stats.
4. Fixture UI for match stats.
