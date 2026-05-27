Phase 29 - Real-Time Matchday Simulation
========================================

Status
------
Slice 10 complete. Phase 29 is complete. Follow-up substitution interaction work
continues in Phase 30.


Goal
----
Replace the current manual 15-minute fixture clock with a server-authoritative
matchday simulation flow. A matchday contains every fixture in the same
competition edition, round, and date. For now, all matches in that leg happen at
the same time.


Core Rules
----------
- `Start Match Clock` starts the whole simultaneous matchday, not only the
  selected fixture.
- `Simulate Match` instantly simulates the whole simultaneous matchday.
- The browser never owns match time. JavaScript may poll/render state and send
  commands, but the server calculates minutes and applies events.
- A live matchday lasts about 20 real seconds: 10 seconds for each half.
- Pausing freezes the whole matchday.
- Clicking any live fixture pauses the matchday and focuses that fixture.
- Manager decisions are only available while the live matchday is paused and the
  focused fixture involves the manager's club.
- Completed matchdays show all fixture badges, fixture detail, timeline, and
  standings movement.


Grouping
--------
The initial implementation groups simultaneous fixtures by:
- `tournament_edition_id`
- `round`
- `scheduled_on`

Later phases can replace this with kickoff windows or staggered schedules.


Planned Slices
--------------
- Slice 1: matchday session model, fixture grouping, and foundational tests.
  Implemented with `MatchdaySession` and `MatchdaySessionStarter`.
- Slice 2: server-authoritative clock calculation with start, pause, resume,
  half, and full-time state. Implemented with `MatchdayClock`.
- Slice 3: deterministic live event planning and due-event application. Implemented
  with `MatchdayEvent`, `MatchdayEventPlanner`, and `LiveMatchEventApplier`.
- Slice 4: routes/controllers for start, pause, resume, and focused fixture
  selection. Implemented with fixture member endpoints.
- Slice 5: pre-match fixture page remodel with three vertical match columns:
  home club, match controls, and away club. Implemented on the fixture show page.
- Slice 6: live matchday screen listing all simultaneous fixtures and pausing on
  fixture selection. Implemented on the fixture show page.
- Slice 7: paused fixture detail with manager controls only for the managed
  fixture. Implemented with `FixtureManagerDecisions`.
- Slice 8: instant whole-matchday simulation flow. Implemented with
  `MatchdayInstantSimulator`.
- Slice 9: standings movement snapshots and completed matchday result screen.
  Implemented with `MatchdayStandingSnapshot`.
- Slice 10: final polish, tests, and documentation audit. Implemented with
  `MatchdaySessionFinalizer` wiring for live full-time completion.


Main Objects
------------
- `MatchdaySession`
- `MatchdaySessionStarter`
- `MatchdayClock`
- `MatchdayEventPlanner`
- `LiveMatchEventApplier`
- `MatchdaySessionFinalizer`
- `MatchdayStandingSnapshot`


Implemented
-----------
- `MatchdaySession` persists the server-owned matchday object.
- Sessions are unique per `career`, `tournament_edition`, `scheduled_on`, and
  `round`.
- Sessions can point to a focused fixture.
- Focused fixtures must belong to the same matchday grouping.
- `MatchdaySession#fixtures` returns all simultaneous fixtures in stable order.
- `MatchdaySessionStarter` creates or reuses the session for a selected fixture.


Verified
--------
- Matchday grouping includes simultaneous fixtures in the same edition, round,
  and date.
- Fixtures from other matchdays are excluded.
- Invalid focused fixtures are rejected.
- Starting the same matchday twice reuses the existing session.
- `MatchdayClock` starts sessions from server time.
- `MatchdayClock` refreshes minutes from elapsed server time.
- Pausing stores elapsed seconds and freezes the session.
- Resuming continues from stored elapsed seconds.
- Full time is reached when elapsed seconds meet the configured duration.
- `MatchdayEvent` stores planned hidden events separately from visible
  `MatchEvent` records.
- `MatchdayEventPlanner` creates deterministic planned events for every fixture
  in a session.
- `LiveMatchEventApplier` creates visible `MatchEvent` records only when planned
  events are due.
- Applied planned events are marked with `applied_at` so polling cannot create
  duplicate timeline events.
- Fixture routes can start a matchday session for a selected fixture.
- Starting a matchday session also plans hidden matchday events.
- Fixture routes can pause, resume, and focus the current matchday session.
- Fixture show now renders three vertical match columns: home club, center match
  controls, and away club.
- Home and away columns render club identity, formation, and a History feed that
  can include completed and scheduled fixtures.
- History feeds render a five-match context window: two previous fixtures, the
  current fixture highlighted, and two next fixtures when available.
- The center column renders score/status/actions, then Timeline for completed
  fixtures or Manager Decisions for scheduled fixtures, then numbered standings.
- Standings highlight both clubs involved in the focused fixture.
- Running and paused matchday sessions render a Live Matchday board above the
  fixture detail.
- The Live Matchday board lists every simultaneous fixture in the session,
  highlights the manager's fixture, and highlights the focused fixture.
- Clicking any simultaneous fixture routes through the server, pauses the
  matchday, focuses that fixture, and redirects to its fixture page.
- Fixtures outside the manager's club are accessible only when they belong to
  the active career matchday session.
- Manager decision controls are hidden while a matchday is running.
- Paused matchdays expose manager decision controls only on the manager's own
  fixture.
- Neutral focused fixtures stay read-only and explain that decisions are only
  available for the manager's club.
- `Simulate Match` now simulates every fixture in the simultaneous matchday
  group, not only the selected fixture.
- Instant simulation creates/reuses a matchday session, marks each fixture's
  match state full time, completes the session, and advances the career date.
- Matchday standings snapshots record before/after positions for each
  participation in the matchday competition.
- Completed matchday pages keep the fixture badge board visible so the user can
  switch between results.
- Completed matchday standings render movement hints when snapshot data exists.
- `MatchdaySessionFinalizer` runs the existing match/stat/standings pipeline
  when a live server clock reaches full time.
- Both instant simulation and live full-time completion now go through matchday
  session finalization.
- Live matchday mode defaults to the matchday board only.
- Focused fixture detail is rendered only after selecting a fixture from the
  matchday board.
- Focused fixture detail links back to the matchday board instead of the club
  dashboard.
- Running matchday boards poll through Turbo/Stimulus so the page keeps asking
  the server for the authoritative minute, events, and finalization state.
- Running matchday boards now poll a lightweight JSON status endpoint every
  500ms instead of reloading the full page on every tick.
- Matchday duration is now 60 seconds to give the live board more updates over a
  longer running match.
- Live match cards are stacked with fixed score-card sizing and a timeline area
  under each card for goals, cards, and other visible events.
- The matchday board groups the manager's fixture first under Your matches, then
  lists the rest under Other matches.
- Matchday cards use full club names and show only the latest visible highlight
  below each score row.
- Detail mode hides the Live Matchday board; returning to the board requires the
  Back to matchday button.
- Planned matchday events include goals, so score changes are created during the
  live clock instead of only at full time.
- Full-time finalization preserves the live-created timeline and scores fixtures
  from the visible goal events already applied by the live clock.
- Fixture detail badges distinguish Scheduled, Under Way, and Completed states.
- History rows show the state badge first, then a compact score chip for
  completed or live fixtures; live score chips use the yellow result tone.
- Fixture detail standings show #, Club with crest, Pts, MP, W, D, L, and GD.
- Completed-match timeline events render as message rows aligned to the home or
  away side based on the event club.
- Fixture pages now map to named screen partials: Match Screen, Live Matchday
  Screen, and the focused Live Match Screen that reuses the Match Screen layout.
- Match Screen side columns render club identity, formation, and Manager
  Decisions before and during matches. Only the manager's club exposes enabled
  controls; the opposition side shows read-only formation and mentality.
- Completed Match Screens hide Manager Decisions cards.
- Scheduled Match Screens render Joint History in the center column, with home
  history left, away history right, and the current fixture centered and
  emphasized.
- Under Way and Completed Match Screens render Timeline in the center column.


Frontend Target
---------------
Before kickoff:
- Three columns: home club identity, center score/actions, away club identity.
- Home and away columns include formation and side-specific Manager Decisions
  below the identity block.
- Center column includes Joint History and numbered standings below the
  score/action block.

Live mode:
- All simultaneous fixtures render together.
- The manager's fixture is visually highlighted.
- Clicking a fixture pauses the matchday and focuses that fixture.
- Focused managed fixture exposes tactical controls while paused.

Completed mode:
- Matchday fixture badges appear at the top.
- Clicking a badge changes the focused fixture.
- Match Screen keeps side Manager Decisions disabled/enabled by club ownership
  and swaps Joint History for Timeline in the center column.
- Final standings render as a full-width block with position movement hints.


Implementation Notes
--------------------
- Avoid client-side authority for minute, score, events, or finalization.
- Event generation should be deterministic and idempotent.
- Finalization currently uses `MatchSimulator` as the compatibility layer for
  fixtures, match stats, athlete season stats, standings, trophies, and news.
- Future work can replace the compatibility finalizer with a live-native
  simulator that preserves every planned live event exactly.
