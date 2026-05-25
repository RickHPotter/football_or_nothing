Phase 2 - Club Management Skeleton
==================================

Status
------
Implemented at first-playable depth.


Goal
----
Expose the manager career and current club as the main game surface without
letting the player act as a club owner.


Main Files
----------
- `app/controllers/careers_controller.rb`
- `app/controllers/clubs_controller.rb`
- `app/controllers/athletes_controller.rb`
- `app/controllers/manager_contracts_controller.rb`
- `app/views/careers/show.html.erb`
- `app/views/clubs/show.html.erb`
- `app/views/athletes/show.html.erb`


Implemented
-----------
- Manager dashboard.
- Current club dashboard.
- Squad list.
- Athlete profile.
- Contract and wage display.
- Job selection/taking for eligible clubs.
- Club financial summary.
- Manager contract records connecting managers to clubs.


Behavior
--------
The player controls a manager who can take a job at a club. Club data is
visible and actionable through the manager role, but ownership-level behavior is
outside the player scope.


Tests
-----
Covered by career, club, athlete, and manager-contract controller/model tests.


Deferred
--------
- Rich job negotiations.
- Manager firing/resignation depth.
- Board expectations.
- Club owner administration.
