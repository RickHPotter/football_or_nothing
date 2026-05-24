Phase Status Audit
==================

Purpose
-------
This document separates implemented first-playable behavior from deferred depth
so the next phase can be chosen deliberately.


Summary
-------
Phases 1 through 23 are implemented enough to support the current first
playable loop.

There are no blocking leftovers from phases 1 through 23 that must be completed
before starting Phase 24.

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
- Data import foundation.


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


Worth Considering Before Phase 24
---------------------------------
These are not blockers, but they are close enough to UI polish that they may
affect Phase 24 design:

- Many screens repeat panel/table/badge markup directly.
- Navigation does not yet highlight active sections.
- Empty states and mobile density are inconsistent across newer feature screens.


Recommended Next Step
---------------------
Proceed to Phase 24 - UI System Polish.

Phase 24 should focus on small reusable view helpers and navigation polish
without changing the game loop.
