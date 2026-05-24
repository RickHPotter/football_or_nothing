Phase 20 - News Feed
====================

Status
------
Implemented at first-playable depth.


Goal
----
Make the world feel alive and explain important events to the player.


Main Files
----------
- `app/models/news_item.rb`
- `app/models/news_publisher.rb`
- `app/models/match_simulator.rb`
- `app/models/transfer_processor.rb`
- `app/models/tournament_finalizer.rb`
- `app/services/season_rollover.rb`
- `app/models/youth_intake_generator.rb`
- `app/models/youth_promotion_processor.rb`
- `app/controllers/careers_controller.rb`
- `app/controllers/clubs_controller.rb`
- `app/views/careers/show.html.erb`
- `app/views/clubs/show.html.erb`


Data Model
----------
`NewsItem`
- Optional links to career, club, athlete, manager, and tournament edition.
- Category.
- Title.
- Body.
- Occurred date.

Categories:
- match
- transfer
- injury
- discipline
- trophy
- contract
- youth
- world


Behavior
--------
`NewsPublisher` creates idempotent news items.

Current publishers:
- Match simulation publishes match-result news for both clubs.
- Transfer completion publishes transfer news.
- Tournament finalization publishes trophy news.
- Season rollover publishes next-season news for participating clubs.
- Youth intake generation publishes youth intake news.
- Youth promotion publishes academy promotion news.


UI
--
- Career dashboard news panel for the current club.
- Club dashboard recent club news panel.


Tests
-----
Covered by publisher tests plus event-hook tests through transfer, youth,
match, tournament, and rollover paths. Full suite passed when the phase was
committed.


Deferred
--------
- Press conferences.
- Media reputation.
- Fan reaction.
- Player morale reactions to media.
- Dedicated full news page.
- Full career/world scoped feed across multiple clubs.
