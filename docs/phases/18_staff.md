Phase 18 - Staff
================

Status
------
Implemented at first-playable depth.


Goal
----
Model non-player personnel that influence training and scouting.


Main Files
----------
- `app/models/staff_member.rb`
- `app/models/staff_contract.rb`
- `app/models/staff_hiring_processor.rb`
- `app/controllers/staff_contracts_controller.rb`
- `app/views/staff_contracts/index.html.erb`
- `app/models/training_applier.rb`
- `app/models/scouting_assignment_processor.rb`
- `app/models/club.rb`


Data Model
----------
`StaffMember`
- Belongs to country.
- Has role, reputation, status, and role-relevant attributes.

Roles:
- assistant manager
- coach
- fitness coach
- scout
- physio

Attributes:
- coaching
- fitness
- scouting
- judging ability
- judging potential
- physiotherapy
- discipline
- motivation

`StaffContract`
- Links staff member to club.
- Tracks wage, start date, end date, current flag, and status.


Behavior
--------
- Clubs can hire free staff from the staff screen.
- Staff wages count against available wage budget.
- Coaches can improve training growth.
- Fitness coaches can reduce training condition pressure.
- Scouts can improve scouting report confidence.


UI
--
- Staff screen.
- Current staff table.
- Available staff hiring table.


Tests
-----
Covered by hiring processor tests, staff controller tests, training modifier
tests, and scouting modifier tests. Full suite passed when the phase was
committed.


Deferred
--------
- Staff personalities.
- Staff poaching.
- Deep staff wage-budget accounting.
- Physio injury-duration effects.
- Assistant squad and match advice.
- UI explanation for exact staff modifiers.
