Phase 19 - Youth Academy
========================

Status
------
Implemented at first-playable depth.


Goal
----
Create a long-term squad-building path through generated youth prospects.


Main Files
----------
- `app/models/youth_intake.rb`
- `app/models/youth_intake_generator.rb`
- `app/models/youth_promotion_processor.rb`
- `app/controllers/youth_intakes_controller.rb`
- `app/views/youth_intakes/index.html.erb`
- `app/controllers/clubs_controller.rb`
- `app/views/clubs/show.html.erb`
- `app/models/club.rb`
- `app/models/athlete.rb`


Data Model
----------
`Club`
- Has `academy_quality`.

`YouthIntake`
- Belongs to club.
- Tracks season year and generation date.
- Owns generated academy prospects.

`Athlete`
- Optional `youth_intake`.
- `youth_academy_player` flag.
- `academy_graduate` flag.


Behavior
--------
- Clubs can generate one youth intake per season.
- Prospects are generated without senior contracts.
- Prospect potential depends on club reputation, country reputation, and
  academy quality.
- Managers can promote a prospect to the senior squad.
- Promotion creates a current athlete contract.
- Promotion marks the athlete as an academy graduate.
- News feed integration was added in Phase 20.


UI
--
- Youth academy screen.
- Generate intake action.
- Prospect table.
- Promote action.
- Club dashboard youth academy panel.


Tests
-----
Covered by intake generator tests, promotion processor tests, and youth
controller tests. Full suite passed when the phase was committed.


Deferred
--------
- Youth competitions.
- Youth coaches.
- Training groups.
- Youth poaching.
- Academy investment and operating costs.
- Richer intake outliers and personalities.
