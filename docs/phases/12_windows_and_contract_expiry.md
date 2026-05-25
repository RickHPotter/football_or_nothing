Phase 12 - Windows and Contract Expiry
======================================

Status
------
Implemented at first-playable depth.


Goal
----
Add basic calendar limits to transfers and expire contracts during season
transition.


Main Files
----------
- `app/models/transfer_window_policy.rb`
- `app/models/contract_expiry_processor.rb`
- `app/services/season_rollover.rb`


Implemented
-----------
- Transfer-window policy.
- Transfers allowed during preseason and short postseason windows.
- Transfer offers and finalization blocked outside the transfer window.
- Contract expiry processor for athlete contracts.
- Current athlete contracts expired before the next season starts during
  rollover.


Behavior
--------
Transfers are no longer always available, and expired contracts stop being
current when a new season begins.


Tests
-----
Covered by transfer window policy, transfer offer processor, contract expiry,
and season rollover tests.


Deferred
--------
- Persisted transfer-window records.
- Per-country transfer-window configuration.
- Contract renewal negotiations.
- Free-agent consequences for expired contracts.
- Squad registration rules.
