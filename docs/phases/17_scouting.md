Phase 17 - Scouting
===================

Status
------
Implemented at first-playable depth.


Goal
----
Make recruitment depend on discovery and imperfect information.


Main Files
----------
- `app/models/scouting_assignment.rb`
- `app/models/scout_report.rb`
- `app/models/scouting_assignment_processor.rb`
- `app/controllers/scouting_assignments_controller.rb`
- `app/controllers/careers_controller.rb`
- `app/controllers/transfers_controller.rb`
- `app/views/scouting_assignments/index.html.erb`
- `app/views/transfers/index.html.erb`


Data Model
----------
`ScoutingAssignment`
- Belongs to a club.
- Optional country target.
- Optional position target.
- Tracks focus, status, start date, and end date.

`ScoutReport`
- One report per club/player.
- Stores observed current ability, observed potential, confidence, summary, and
  creation date.


Behavior
--------
- Managers can create scouting assignments from the scouting screen.
- Assignments can target country, position, and focus.
- Date advancement processes completed active assignments.
- Completed assignments generate reports for matching players outside the
  manager's current squad.
- Transfer market hides exact ability for unscouted players.
- Transfer market shows observed ability and confidence for scouted players.
- Staff from Phase 18 can improve report confidence.


UI
--
- Scouting screen with assignment creation and recent reports.
- Transfer market known/unscouted display.


Tests
-----
Covered by focused model tests for assignment processing and controller tests
for assignment creation. Full suite passed when the phase was committed.


Deferred
--------
- Hidden attributes beyond current/potential ability uncertainty.
- Scouting costs.
- International restrictions.
- Athlete profile scouting context for non-owned targets.
- Advanced searches by reputation and ability range.
