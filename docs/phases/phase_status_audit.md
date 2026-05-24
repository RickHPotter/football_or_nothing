Phase Status Audit
==================

Purpose
-------
This document separates implemented first-playable behavior from deferred depth
so the next phase can be chosen deliberately.


Summary
-------
Phases 1 through 22 are implemented enough to support the current first
playable loop.

There are no blocking leftovers from phases 1 through 22 that must be completed
before starting Phase 23.

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
- Tactical simulation and match stats.
- International competition generation.


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


Worth Considering Before Phase 23
---------------------------------
These are not blockers, but they are close enough to real-data import that they
may affect Phase 23 design:

- Generated data has no external identity fields yet.
- Import behavior needs to coexist with generated fictional data.
- Imports should be idempotent and should not overwrite save history.


Recommended Next Step
---------------------
Proceed to Phase 23 - Data Import Foundation.

Phase 23 should focus on import identity fields, import runs, and idempotent
service objects for countries, clubs, athletes, and contracts.
