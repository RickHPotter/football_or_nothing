Phase 29 - Real-Time Matchday Simulation
========================================

Status
------
Slice 5 complete. Slice 6 is next.


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
- Slice 5: pre-match fixture page remodel with a stronger hero and two
  three-column tactical/context blocks. Implemented on the fixture show page.
- Slice 6: live matchday screen listing all simultaneous fixtures and pausing on
  fixture selection.
- Slice 7: paused fixture detail with manager controls only for the managed
  fixture.
- Slice 8: instant whole-matchday simulation flow.
- Slice 9: standings movement snapshots and completed matchday result screen.
- Slice 10: final polish, tests, and documentation audit.


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
- Fixture show now renders a stronger match hero with home/away clubs, score
  state, matchday clock controls, and instant simulation.
- Fixture show now renders the first three-column block as home formation,
  manager decisions, and away formation.
- Fixture show now renders the second three-column block as home recent form,
  standings, and away recent form.


Frontend Target
---------------
Before kickoff:
- Top hero with home and away crests, score/versus state, competition details,
  stadium/date, and the start/simulate controls.
- First three-column block: home formation, manager decisions, away formation.
- Second three-column block: home recent matches, standings, away recent
  matches.

Live mode:
- All simultaneous fixtures render together.
- The manager's fixture is visually highlighted.
- Clicking a fixture pauses the matchday and focuses that fixture.
- Focused managed fixture exposes tactical controls while paused.

Completed mode:
- Matchday fixture badges appear at the top.
- Clicking a badge changes the focused fixture.
- First three-column block: home detail, timeline, away detail.
- Final standings render as a full-width block with position movement hints.


Implementation Notes
--------------------
- Avoid client-side authority for minute, score, events, or finalization.
- Event generation should be deterministic and idempotent.
- Finalization should update fixtures, match stats, athlete season stats,
  standings, trophies, and news consistently with the current instant simulator.
- The existing `MatchSimulator` can remain as a compatibility layer while the
  matchday services are introduced.
