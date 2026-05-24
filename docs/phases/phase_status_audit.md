Phase Status Audit
==================

Purpose
-------
This document separates implemented first-playable behavior from deferred depth
so the next phase can be chosen deliberately.


Summary
-------
Phases 1 through 21 are implemented enough to support the current first
playable loop.

There are no blocking leftovers from phases 1 through 21 that must be completed
before starting Phase 22.

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


Worth Considering Before Phase 22
---------------------------------
These are not blockers, but they are close enough to international competitions
that they may affect Phase 22 design:

- `Club#international` exists, but the app does not yet distinguish club teams
  from national teams beyond a flag.
- Calendar conflicts are still simple.
- The UI has no tournament detail page yet, so international competition
  visibility will initially need to live on career/club screens.


Recommended Next Step
---------------------
Proceed to Phase 22 - International Competitions.

Phase 22 should focus on creating a small international competition path without
disrupting the domestic league loop.
