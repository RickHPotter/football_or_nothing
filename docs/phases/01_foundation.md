Phase 1 - Foundation
====================

Status
------
Implemented at first-playable depth.


Goal
----
Create the core Rails application, authentication flow, and minimum football
world needed for a playable manager career.


Main Files
----------
- `app/models/user.rb`
- `app/models/career.rb`
- `app/models/manager.rb`
- `app/models/country.rb`
- `app/models/club.rb`
- `app/models/club_finance.rb`
- `app/models/stadium.rb`
- `app/models/athlete.rb`
- `app/models/athlete_contract.rb`
- `app/services/world_generator.rb`
- `app/controllers/registrations_controller.rb`
- `app/controllers/sessions_controller.rb`
- `app/controllers/passwords_controller.rb`


Implemented
-----------
- Rails authentication with sign up, sign in, sessions, and password reset
  support.
- User-owned career records.
- Manager identity separate from club ownership.
- Countries, clubs, club finances, stadiums, athletes, athlete attributes, and
  athlete contracts.
- Fictional world generation for a small playable database.
- Initial club financial profiles and contract data.


Behavior
--------
The generated world creates enough data for one manager to start a career,
choose a club, view a squad, and enter the first domestic competition loop.


Tests
-----
Covered by model and controller tests for authentication, careers, managers,
clubs, countries, athletes, contracts, finances, and world generation behavior.


Deferred
--------
- Real-world data.
- Multiple generated countries.
- Detailed wage negotiation.
- Club ownership mechanics.
