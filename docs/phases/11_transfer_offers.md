Phase 11 - Transfer Offers
==========================

Status
------
Implemented at first-playable depth.


Goal
----
Separate transfer negotiation intent from completed player movement.


Main Files
----------
- `app/models/transfer_offer.rb`
- `app/models/transfer_offer_processor.rb`
- `app/controllers/transfers_controller.rb`
- `app/views/transfers/index.html.erb`


Implemented
-----------
- Transfer offers as negotiation records.
- Pending offers from the transfer market.
- Offered fee, wage, source club, target club, expiry, and status.
- Finalization of acceptable pending offers into completed transfers.
- Recent offers shown alongside completed transfer history.
- Budget and wage validation through the existing transfer processor.


Behavior
--------
The manager can submit offers first and finalize valid offers later, giving the
transfer flow a negotiation state instead of immediate movement only.


Tests
-----
Covered by transfer offer processor and transfer controller tests.


Deferred
--------
- Selling-club AI decisions.
- Counter offers.
- Loan offers.
- Transfer windows.
- Release clauses as hard selling rules.
- Offer expiry automation.
