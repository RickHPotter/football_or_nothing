Phase 14 - Loans
================

Status
------
Implemented at first-playable depth.


Goal
----
Support temporary player movement without destroying the parent club contract.


Main Files
----------
- `app/models/transfer.rb`
- `app/models/transfer_offer.rb`
- `app/models/transfer_processor.rb`
- `app/models/transfer_offer_processor.rb`
- `app/models/athlete_contract.rb`
- `app/models/loan_expiry_processor.rb`
- `app/models/contract_expiry_processor.rb`
- `app/services/season_rollover.rb`
- `app/views/transfers/index.html.erb`


Data Model
----------
Transfers and transfer offers support `transfer_type: loan`.

Loan contracts are represented with `AthleteContract`:
- `loan`
- `loan_ends_on`
- `parent_athlete_contract_id`

The active squad rule remains simple: the athlete belongs to the club with the
current contract. On loan, the parent contract is preserved but set
non-current; the loan club receives the current contract.


Behavior
--------
- The transfer market can submit permanent buy offers and loan offers.
- Loan finalization creates a completed loan transfer.
- Loan finalization creates a current loan contract at the destination club.
- Parent contracts are not terminated during a loan.
- Loaned-in players appear in the loan club squad through current contracts.
- Loaned-out players disappear from the parent club squad through current
  contract rules.
- `LoanExpiryProcessor` expires active loans before normal contract expiry.
- Loan expiry restores the parent contract as current.


UI
--
- Transfer market has buy and loan actions.
- Open offers show transfer type and loan end date.
- Recent transfers show transfer type and loan end date.


Tests
-----
Covered by focused model tests for transfer processing, offer finalization, and
loan expiry. Full suite passed when the phase was committed.


Deferred
--------
- Loan recalls.
- Buy options.
- Complex wage splits.
- AI loan negotiations.
- Club dashboard loan labels.
- Athlete profile loan context.
