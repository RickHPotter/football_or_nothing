Phase 9 - Frontend Playable UI Pass
===================================

Status
------
Implemented at first-playable depth.


Goal
----
Make the playable loop readable and game-like through a compact Tailwind UI.


Main Files
----------
- `app/assets/stylesheets/application.tailwind.css`
- `app/views/layouts/application.html.erb`
- `app/views/home/index.html.erb`
- `app/views/careers/show.html.erb`
- `app/views/clubs/show.html.erb`
- `app/views/fixtures/show.html.erb`
- `app/views/transfers/index.html.erb`
- `app/views/athletes/show.html.erb`


Implemented
-----------
- Tailwind CSS build pipeline.
- Compact game layout and top navigation.
- Shared utility classes for panels, stat tiles, tables, badges, buttons,
  flashes, and forms.
- Redesigned home, auth, career creation, dashboard, club, fixture, transfer,
  and athlete screens.
- Dense data-first visual direction suited to a football management game.


Behavior
--------
The main loop is usable through browser screens rather than console-only flows.


Tests
-----
Covered by existing controller rendering tests and helper-level checks added in
later UI phases.


Deferred
--------
- Full visual design system.
- Mobile polish beyond basic responsiveness.
- Icons and richer interaction affordances.
- Dedicated history/news screen.
- Advanced match visualizations.
