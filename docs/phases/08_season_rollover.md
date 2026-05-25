Phase 8 - Season Rollover
=========================

Status
------
Implemented at first-playable depth.


Goal
----
Continue a completed league into a new season without losing historical data.


Main Files
----------
- `app/services/season_rollover.rb`
- `app/models/contract_expiry_processor.rb`
- `app/controllers/careers_controller.rb`


Implemented
-----------
- Next tournament edition creation from a completed edition.
- Participating clubs carried forward.
- Fresh tournament participations with reset standings.
- New fixtures through the existing league scheduler.
- Previous season history preservation.
- Career-page action when no upcoming fixture exists and rollover is available.
- Career date advancement to the first fixture of the new season.
- Duplicate rollover protection.
- Athlete contract expiry before the next season starts.


Behavior
--------
After season completion, the player can roll forward into a new season and keep
playing the same career.


Tests
-----
Covered by season rollover and contract expiry tests.


Deferred
--------
- Promotion and relegation.
- Transfer windows.
- AI club squad changes.
- Calendar conflicts.
- Cup and international competition rollover.
- Season financial accounting.
- Full preseason.
