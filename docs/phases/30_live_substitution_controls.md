Phase 30 - Live Substitution Controls
=====================================

Status
------
Slices 1 and 2 complete. Slice 3 is in progress.


Goal
----
Replace form-based live lineup changes with a visual pitch-and-bench interface
that supports substitutions during a paused live match. The manager should be
able to inspect both formations, drag players between valid areas, and submit a
server-validated substitution without relying on the current `Swap Players` or
`Make substitution` forms.

This phase also fixes a live completion bug: after a matchday reaches 90
minutes and finalizes, the focused fixture detail screen must show `Completed`,
not `Scheduled`.


Screen Names
------------
- Match Screen: the three-column fixture detail for scheduled or completed
  fixtures.
- Live Matchday Screen: the board showing all simultaneous fixtures.
- Live Match Screen: the focused fixture detail while the matchday is under
  way or paused.


Problems To Solve
-----------------
- Live substitutions are currently exposed through ordinary forms that do not
  match the intended game feel.
- `Swap Players` is conceptually pre-match only and does not belong in live
  Manager Decisions.
- `Make substitution` duplicates the intended live interaction and should be
  replaced by field/bench interaction.
- The current formation display is readable but still feels like a list laid
  over a pitch; it needs stronger football-field visual language.
- Players should be draggable in the UI, but the server must remain the
  authority for whether a substitution is legal.
- A live matchday can reach full time while the focused fixture detail still
  renders as `Scheduled`.
- AI substitutions must never manage the user's club. If the manager does not
  substitute their own players, their lineup stays unchanged.
- Successful match actions should not create flash notices or alerts. Only
  invalid/blocked actions may surface an error to the user.


Planned Slices
--------------

Slice 1: live completion state audit and bug fix
- Reproduce the case where a live matchday reaches 90 minutes but the focused
  fixture detail still shows `Scheduled`.
- Trace `MatchdayClock`, `LiveMatchEventApplier`, `MatchdaySessionFinalizer`,
  `MatchdayStatusPayload`, and `FixturesController#show`.
- Ensure finalization updates every matchday fixture status to `completed`.
- Ensure the focused fixture is reloaded after finalization before rendering.
- Add regression coverage for visiting `careers/:career_id/fixtures/:id?details=true`
  after the server clock reaches full time.

Implemented:
- `FixturesController#refresh_matchday_session` reloads the focused fixture
  after live finalization completes.
- Regression coverage verifies that a full-time focused Live Match Screen
  renders the `Completed` badge and Timeline.

Slice 2: split pre-match swaps from live substitutions
- Keep pre-match lineup swap behavior available only before kickoff if it is
  still needed.
- Remove the `Swap Players` and `Make substitution` form sections from live
  Manager Decisions.
- Preserve formation and mentality controls where they still make sense.
- Add tests that live paused screens do not render the old swap/substitution
  form controls.

Implemented:
- Manager Decisions no longer renders the old `Swap players` or `Make
  substitution` form sections.
- Existing server endpoints still exist for now, but successful lineup actions
  no longer emit flash notices.
- Regression coverage verifies the old form submit buttons are absent from the
  Match Screen.

Slice 3: pitch formation component
- Replace the current compact formation list board with a richer pitch visual.
- Keep formation rows and slot positions driven by `LineupBoard` and
  `LineupTemplate`; do not hard-code per-screen layouts.
- Render each starter as a player token with:
  - shirt/slot label
  - player name
  - position or tactical role
  - status markers for cards, injury, substitution state, or low condition when
    available
- Make home and away pitch components visually consistent.
- Keep the layout stable on desktop and mobile.

Slice 4: bench/substitute rail
- Render available substitutes below each pitch.
- Show unavailable bench players distinctly:
  - already substituted on
  - already substituted off
  - injured
  - suspended or otherwise unavailable
- Display remaining substitutions for each club.
- For the manager's club, mark legal substitution candidates as interactive.
- For the opposition, keep the bench read-only.

Slice 5: drag-and-drop interaction
- Add a Stimulus controller for drag selection.
- Allow dragging a bench player onto a starter slot for the managed club while
  the matchday is paused.
- Support a click-first fallback for users who do not drag.
- Preview the pending change before submission.
- Do not mutate the lineup locally as authoritative state; submit the proposed
  substitution to Rails.
- Keep JavaScript as UI only. It may choose IDs and render previews, but it must
  not decide legality.

Slice 6: server substitution endpoint hardening
- Keep or reshape the existing substitution endpoint around the new UI payload:
  - fixture
  - outgoing lineup athlete
  - incoming lineup athlete
  - current match minute
- Validate on the server:
  - matchday exists
  - matchday is paused
  - fixture involves the manager's club
  - fixture is not completed
  - outgoing player is an active starter
  - incoming player is an unused bench player
  - substitution limit has not been reached
  - both lineup athletes belong to the same lineup and fixture
- Apply the substitution transactionally.
- Create a timeline substitution event.
- Return the user to the Live Match Screen with updated pitch and bench state.

Slice 7: live timeline and board refresh integration
- After a successful substitution, the focused Live Match Screen should show the
  updated Timeline entry.
- The Live Matchday Screen should show the latest substitution highlight for
  the fixture if it is the most recent event.
- Resuming the matchday should continue from the server-owned paused minute.

Slice 8: AI and opponent behavior alignment
- Confirm AI substitutions still use the same lineup state rules.
- Ensure AI substitutions do not conflict with manager substitutions.
- Ensure the opponent pitch/bench can reflect AI substitution state in read-only
  mode.
- Ensure AI substitution planning skips the manager's club in every live
  matchday fixture. The user's lineup changes only through user action.

Slice 9: visual polish and accessibility
- Use a field-like visual treatment rather than table/list styling.
- Keep text readable and non-overlapping in long names.
- Add hover/focus states for interactive player tokens.
- Make disabled/opponent tokens visibly read-only.
- Preserve keyboard-accessible fallback for selecting outgoing and incoming
  players.

Slice 10: documentation, tests, and cleanup
- Update Phase 30 with implemented details.
- Update Phase 28 notes if any old substitution controls are retired.
- Remove dead view branches, obsolete tests, and stale copy.
- Run focused controller/model/system-style tests where available.
- Run full Rails tests and RuboCop.


Expected Data/Code Areas
------------------------
- `app/views/fixtures/_formation_card.html.erb`
- `app/views/fixtures/_manager_decisions_card.html.erb`
- `app/views/fixtures/_timeline_card.html.erb`
- `app/views/fixtures/_live_matchday_screen.html.erb`
- `app/controllers/fixtures_controller.rb`
- `app/models/lineup_board.rb`
- `app/models/lineup_athlete.rb`
- `app/models/lineup_swapper.rb`
- `app/models/ai_substitution_planner.rb`
- `app/models/matchday_session_finalizer.rb`
- `app/javascript/controllers/*`
- `test/controllers/fixtures_controller_test.rb`
- `test/controllers/matchday_sessions_controller_test.rb`
- `test/models/ai_substitution_planner_test.rb`


Acceptance Criteria
-------------------
- A completed live matchday always renders completed fixture details.
- Scheduled Match Screens still allow pre-match tactical setup.
- Live Match Screens no longer show the old `Swap Players` or `Make
  substitution` forms.
- A paused managed Live Match Screen shows an interactive pitch and bench.
- The manager can substitute by dragging or selecting a bench player and a
  starter.
- Illegal substitutions are rejected server-side with clear feedback.
- Successful substitutions, tactical changes, pauses, resumes, and other valid
  match actions do not show flash notices.
- Substitution counters, lineup state, and timeline events update correctly.
- Opposition formations and benches are visible but read-only.
- AI substitutions apply only to non-managed clubs.
- Live Matchday Screen can show the latest substitution highlight.
- Existing instant simulation and AI substitution behavior still pass tests.


Non-Goals
---------
- Full tactical match engine rewrite.
- Real-time WebSocket control of drag state.
- New player-condition/fatigue model beyond showing existing data.
- Multi-substitution batch workflows.
- Staggered kickoff times.


Risks
-----
- Drag-and-drop can easily create client-side authority bugs if validation is
  not centralized on the server.
- Long player names and imported club data can break pitch layout if player
  tokens are not constrained.
- Existing live finalization may need reload/transaction cleanup so the UI sees
  completed fixture state immediately.
- AI substitutions and manual substitutions must share the same substitution
  eligibility rules to avoid inconsistent bench state.
