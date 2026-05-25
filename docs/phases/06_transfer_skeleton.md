Phase 6 - Transfer Skeleton
===========================

Status
------
Implemented at first-playable depth.


Goal
----
Allow basic player movement between clubs while preserving transfer and
contract history.


Main Files
----------
- `app/models/transfer.rb`
- `app/models/transfer_processor.rb`
- `app/controllers/transfers_controller.rb`
- `app/views/transfers/index.html.erb`


Implemented
-----------
- Historical transfer records.
- Free transfers.
- Permanent transfers.
- Current contract movement during transfers.
- Old contract/history preservation.
- Basic transfer budget and wage budget checks.
- Transfer-market screen for the current club.


Behavior
--------
The manager can buy players when finances allow it. Completed transfers update
the athlete's current club through contracts while retaining historical records.


Tests
-----
Covered by transfer processor, transfer model, and transfer controller tests.


Deferred
--------
- Loans.
- Release clauses.
- Transfer windows.
- AI club transfer activity.
