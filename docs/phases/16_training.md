Phase 16 - Training
===================

Status
------
Implemented at first-playable depth.


Goal
----
Give the manager a recurring lever for squad development and condition.


Main Files
----------
- `app/models/training_plan.rb`
- `app/models/training_result.rb`
- `app/models/training_applier.rb`
- `app/controllers/training_plans_controller.rb`
- `app/controllers/careers_controller.rb`
- `app/controllers/clubs_controller.rb`
- `app/views/clubs/show.html.erb`


Data Model
----------
`TrainingPlan`
- One active plan per club.
- Belongs to club and manager.
- Tracks focus, intensity, and active date.

Training focuses:
- balanced
- fitness
- attacking
- defending
- technical
- youth development

Training intensities:
- low
- normal
- high

`TrainingResult`
- Records visible development changes.
- Stores athlete, club, plan, changed attribute, old value, new value,
  condition change, and date.


Behavior
--------
- The club dashboard exposes focus and intensity controls.
- Date advancement applies the active plan to the current squad.
- Training changes condition based on intensity.
- Training can increase selected attributes.
- Young/high-potential players can benefit more.
- Staff from Phase 18 can later modify training results.


UI
--
- Club dashboard training panel.
- Recent training results on the club dashboard.


Tests
-----
Covered by model tests for training application and controller tests for plan
updates. Full suite passed when the phase was committed.


Deferred
--------
- Facilities.
- Individual player training.
- Tactical familiarity.
- Athlete profile development history.
- Career dashboard monthly training summary.
