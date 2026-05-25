Phase 7 - RPG Progression
=========================

Status
------
Implemented at first-playable depth.


Goal
----
Make managers, athletes, and clubs evolve over time so the game behaves like a
career RPG rather than a static database.


Main Files
----------
- `app/models/progression_applier.rb`
- `app/models/manager.rb`
- `app/models/athlete.rb`
- `app/models/club.rb`


Implemented
-----------
- Manager reputation.
- Athlete current and potential ability.
- Age-based ability progression and decline.
- Athlete morale and condition.
- Club reputation.
- Manager reputation limits for available jobs.
- Progression application when a tournament edition is finalized.


Behavior
--------
Season completion can improve successful managers/clubs, develop younger
athletes, and decline older athletes. Manager reputation affects which jobs are
realistically available.


Tests
-----
Covered by progression, manager eligibility, athlete, club, and tournament
finalization tests.


Deferred
--------
- Training plans.
- Detailed development curves.
- Injuries and fatigue depth.
- Player personality.
- Dynamic club reputation beyond champion gains.
