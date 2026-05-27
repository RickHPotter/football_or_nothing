Phase Status Audit
==================

Purpose
-------
This document separates implemented first-playable behavior from deferred depth
so the next phase can be chosen deliberately.


Summary
-------
Phases 1 through 29 are implemented enough to support the current first
playable loop.

There are no blocking leftovers from phases 1 through 29 in the first playable
backlog.

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
- Initial UI system polish.
- Real-time simultaneous matchday simulation.
- Named Match, Live Matchday, and Live Match screens.


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
- UI component extraction.
- Visual drag-and-drop substitution controls.


Worth Considering Next
----------------------
These are not blockers, but they are good candidates for the next planning pass:

- Many screens still repeat table and stat tile markup directly.
- Empty states and mobile density are inconsistent across newer feature screens.
- RuboCop currently reports global complexity/style debt in older files.


Recommended Next Step
---------------------
Recommended next step:
Execute Phase 30: live substitution controls, richer pitch visuals, and the
full-time focused-fixture status bug fix.
