# frozen_string_literal: true

module FixturesHelper
  def fixture_status_label(fixture, matchday_session: nil)
    return "Completed" if fixture.completed?
    return "Under Way" if fixture_under_way?(fixture, matchday_session:)

    fixture.status.humanize
  end

  def fixture_status_badge_class(fixture, matchday_session: nil)
    if fixture.completed?
      "badge-good"
    elsif fixture_under_way?(fixture, matchday_session:)
      "badge-warn"
    end
  end

  def fixture_under_way?(fixture, matchday_session: nil)
    return true if fixture.in_progress?
    return true if fixture.match_state&.running? || fixture.match_state&.paused?

    matchday_session_active_for?(fixture, matchday_session)
  end

  def fixture_display_score(fixture, matchday_session: nil, scorelines: {})
    return fixture.scoreline if fixture.completed?
    return scorelines[fixture] || "0-0" if fixture_under_way?(fixture, matchday_session:)

    nil
  end

  private

  def matchday_session_active_for?(fixture, matchday_session)
    return false unless matchday_session&.running? || matchday_session&.paused?

    matchday_session.includes_fixture?(fixture)
  end
end
