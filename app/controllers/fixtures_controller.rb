# frozen_string_literal: true

class FixturesController < ApplicationController
  before_action :set_career
  before_action :set_club
  before_action :set_fixture
  before_action :ensure_match_setup, only: %i[show simulate start pause resume start_matchday pause_matchday resume_matchday focus_matchday advance_clock tactics
                                              regenerate_lineup swap_lineup_athletes update_lineup_role substitute]

  def show
    load_matchday_context
    load_fixture_context
  end

  def simulate
    MatchdayInstantSimulator.call(career: @career, fixture: @fixture)

    redirect_to career_fixture_path(@career, @fixture)
  end

  def start
    @fixture.in_progress! if @fixture.scheduled?
    @fixture.match_state.running!
    @career.update!(current_date: @fixture.scheduled_on) if @career.current_date < @fixture.scheduled_on

    redirect_to career_fixture_path(@career, @fixture)
  end

  def pause
    @fixture.match_state.paused! if @fixture.match_state.running?

    redirect_to career_fixture_path(@career, @fixture)
  end

  def resume
    @fixture.match_state.running! if @fixture.match_state.paused?

    redirect_to career_fixture_path(@career, @fixture)
  end

  def start_matchday
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayEventPlanner.call(session:)
    MatchdayClock.start(session)

    redirect_to career_fixture_path(@career, @fixture)
  end

  def pause_matchday
    session = matchday_session_for(@fixture)
    return redirect_missing_matchday unless session

    session.update!(focused_fixture: @fixture)
    MatchdayClock.pause(session) if session.running?

    redirect_to career_fixture_path(@career, @fixture)
  end

  def resume_matchday
    session = matchday_session_for(@fixture)
    return redirect_missing_matchday unless session

    MatchdayClock.resume(session)

    redirect_to career_fixture_path(@career, @fixture)
  end

  def focus_matchday
    session = matchday_session_for(@fixture)
    return redirect_missing_matchday unless session

    session.update!(focused_fixture: @fixture)
    MatchdayClock.pause(session)

    redirect_to career_fixture_path(@career, @fixture, details: true)
  end

  def advance_clock
    unless @fixture.match_state.running?
      redirect_to career_fixture_path(@career, @fixture), alert: "Start or resume the match clock first."
      return
    end

    next_minute = [ @fixture.match_state.minute + 15, 90 ].min
    @fixture.match_state.update!(minute: next_minute)

    if next_minute == 90
      MatchSimulator.call(@fixture)
      @fixture.match_state.full_time!
    else
      AiSubstitutionPlanner.call(fixture: @fixture, club: opponent_club, minute: next_minute)
    end
    redirect_to career_fixture_path(@career, @fixture)
  end

  def tactics
    lineup = @fixture.lineup_for(@club)
    lineup.update!(tactics_params)
    LineupBuilder.call(lineup:) if @fixture.match_state.not_started?

    redirect_to career_fixture_path(@career, @fixture)
  end

  def regenerate_lineup
    unless @fixture.match_state.not_started?
      redirect_to career_fixture_path(@career, @fixture), alert: "Lineups can only be regenerated before kickoff."
      return
    end

    LineupBuilder.call(lineup: @fixture.lineup_for(@club))

    redirect_to career_fixture_path(@career, @fixture)
  end

  def swap_lineup_athletes
    context = FixtureLineupSwapProcessor.call(
      fixture: @fixture,
      club: @club,
      matchday_session: matchday_session_for(@fixture),
      from_lineup_athlete_id: params.expect(:from_lineup_athlete_id),
      to_lineup_athlete_id: params.expect(:to_lineup_athlete_id)
    )

    redirect_to lineup_swap_redirect_path(context)
  rescue ActiveRecord::RecordNotFound
    redirect_to lineup_swap_redirect_path, alert: lineup_swap_record_not_found_message
  rescue LiveLineupSwapProcessor::Error => e
    redirect_to lineup_swap_redirect_path, alert: e.message
  end

  def update_lineup_role
    unless @fixture.match_state.not_started?
      redirect_to career_fixture_path(@career, @fixture), alert: "Tactical roles can only be changed before kickoff."
      return
    end

    tactical_role = params.expect(:tactical_role)
    unless LineupAthlete.tactical_roles.key?(tactical_role)
      redirect_to career_fixture_path(@career, @fixture), alert: "Choose a valid tactical role."
      return
    end

    @fixture.lineup_for(@club).lineup_athletes.find(params.expect(:lineup_athlete_id)).update!(tactical_role:)

    redirect_to career_fixture_path(@career, @fixture)
  rescue ActiveRecord::RecordNotFound
    redirect_to career_fixture_path(@career, @fixture), alert: "Choose one player from your lineup."
  end

  def substitute
    LiveSubstitutionProcessor.call(
      fixture: @fixture,
      club: @club,
      matchday_session: matchday_session_for(@fixture),
      off_lineup_athlete_id: params.expect(:off_lineup_athlete_id),
      on_lineup_athlete_id: params.expect(:on_lineup_athlete_id)
    )

    redirect_to career_fixture_path(@career, @fixture, details: true)
  rescue ActiveRecord::RecordNotFound, LiveSubstitutionProcessor::Error => e
    redirect_to career_fixture_path(@career, @fixture, details: true), alert: substitution_error_message(e)
  end

  private

  def load_matchday_context
    @matchday_session = matchday_session_for(@fixture)
    refresh_matchday_session
    @matchday_fixtures = @matchday_session&.fixtures || []
    @matchday_scorelines = @matchday_session ? MatchdayScoreboard.call(@matchday_session) : {}
    @matchday_events = MatchdayTimeline.call(@matchday_session, limit: 1)
    @standing_movements = MatchdayStandingMovement.call(@matchday_session)
    @show_fixture_detail = @matchday_session.nil? || params[:details].present?
  end

  def load_fixture_context
    @standings = @fixture.tournament_edition.standings
    @events = @fixture.match_events.includes(:club, :athlete).order(:minute, :id)
    @next_fixture = @career.next_fixture if @fixture.completed?
    @match_state = @fixture.match_state
    @managed_lineup = @fixture.lineup_for(@club)
    @manager_decisions = FixtureManagerDecisions.new(fixture: @fixture, club: @club, lineup: @managed_lineup, matchday_session: @matchday_session)
    @home_lineup = @fixture.lineup_for(@fixture.home_club)
    @away_lineup = @fixture.lineup_for(@fixture.away_club)
    @joint_history_fixtures = FixtureJointHistory.call(fixture: @fixture)
  end

  def set_career
    @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
  end

  def set_club
    @club = @career.manager&.current_club
    redirect_to @career, alert: "Take a job before opening fixtures." unless @club
  end

  def set_fixture
    @fixture = Fixture.includes(:home_club, :away_club, :stadium, :match_events,
                                tournament_edition: [ :tournament, { tournament_participations: :club } ]).find(params.expect(:id))
    return if @fixture.involves?(@club)
    return if matchday_session_for(@fixture)&.includes_fixture?(@fixture)

    raise ActiveRecord::RecordNotFound
  end

  def ensure_match_setup
    return if @fixture.completed?
    return unless @fixture.involves?(@club) || matchday_session_for(@fixture)&.includes_fixture?(@fixture)

    @fixture.ensure_match_setup!
  end

  def tactics_params
    params.expect(lineup: %i[formation mentality])
  end

  def opponent_club
    @opponent_club ||= @fixture.home_club_id == @club.id ? @fixture.away_club : @fixture.home_club
  end

  def matchday_session_for(fixture)
    MatchdaySession.find_by(
      career: @career,
      tournament_edition: fixture.tournament_edition,
      scheduled_on: fixture.scheduled_on,
      round: fixture.round
    )
  end

  def redirect_missing_matchday
    redirect_to career_fixture_path(@career, @fixture), alert: "Start the matchday clock first."
  end

  def refresh_matchday_session
    return unless @matchday_session&.running?

    MatchdayClock.refresh(@matchday_session)
    LiveMatchEventApplier.call(session: @matchday_session)
    MatchdaySessionFinalizer.call(session: @matchday_session, focused_fixture: @fixture).tap { @fixture.reload if @matchday_session.completed? }
  end

  def substitution_error_message(error)
    return "Choose one active starter and one unused substitute." if error.is_a?(ActiveRecord::RecordNotFound)

    error.message
  end

  def lineup_swap_redirect_path(context = nil)
    return career_fixture_path(@career, @fixture) unless context == FixtureLineupSwapProcessor::LIVE_CONTEXT || matchday_session_for(@fixture)&.paused?

    career_fixture_path(@career, @fixture, details: true)
  end

  def lineup_swap_record_not_found_message
    return "Choose two active starters from your lineup." if matchday_session_for(@fixture)&.paused?

    "Choose two players from your lineup."
  end
end
