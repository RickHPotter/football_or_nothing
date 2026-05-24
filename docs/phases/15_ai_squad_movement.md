Phase 15 - AI Squad Movement
============================

Status
------
Implemented at first-playable depth.


Goal
----
Let non-player clubs make basic squad decisions during transfer windows and
season rollover.


Main Files
----------
- `app/models/squad_needs_analyzer.rb`
- `app/models/ai_transfer_planner.rb`
- `app/models/ai_contract_renewal_processor.rb`
- `app/services/season_rollover.rb`


Core Services
-------------
`SquadNeedsAnalyzer`
- Compares the current squad against conservative minimum position counts.
- Returns missing positions and counts.

`AiTransferPlanner`
- Runs for AI clubs during open transfer windows.
- Targets weak positions first.
- Prefers free agents.
- Falls back to affordable permanent transfers.
- Avoids recently moved athletes.
- Respects transfer budget and wage budget.

`AiContractRenewalProcessor`
- Reviews expiring active non-loan athlete contracts.
- Renews useful players if the club can afford the wage.
- Leaves weaker or unaffordable contracts for normal expiry.


Rollover Integration
--------------------
Season rollover now runs:
1. AI contract renewal.
2. Loan expiry.
3. Normal contract expiry.
4. AI transfer planning.
5. Fixture scheduling.


Tests
-----
Covered by focused tests for squad-needs analysis, AI transfers, contract
renewal, and season rollover. Full suite passed when the phase was committed.


Deferred
--------
- Bidding wars.
- Player preferences.
- Agents.
- Advanced squad registration.
- AI loans.
- Dedicated world activity UI beyond the later news feed.
