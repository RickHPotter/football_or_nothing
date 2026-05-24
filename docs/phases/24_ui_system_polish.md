Phase 24 - UI System Polish
===========================

Status
------
Implemented at first-playable depth.


Goal
----
Start turning the Tailwind pass into a reusable game interface system.


Main Files
----------
- `app/helpers/application_helper.rb`
- `app/views/shared/_panel.html.erb`
- `app/views/layouts/application.html.erb`
- `app/assets/stylesheets/application.tailwind.css`


Implemented
-----------
- `game_nav_link` helper for top navigation links.
- Active navigation state with `aria-current`.
- `status_badge` helper for consistent badge markup.
- `panel` helper backed by `shared/_panel`.
- Shared panel partial for future screen extraction.
- Top navigation now uses the helper instead of repeated raw links.
- CSS class for active nav links.


Tests
-----
Covered by helper tests and existing controller view rendering tests.


Deferred
--------
- Replacing all repeated panels across every screen.
- Componentizing all tables and stat tiles.
- Icon pass.
- Mobile-specific layout pass.
- Dedicated tournament/news pages.
