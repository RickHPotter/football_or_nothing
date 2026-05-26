# frozen_string_literal: true

class FixturesController < ApplicationController
  before_action :set_career
  before_action :set_club
  before_action :set_fixture
  before_action :ensure_match_setup,
                only: %i[show simulate start pause resume start_matchday pause_matchday resume_matchday focus_matchday advance_clock tactics regenerate_lineup
                         swap_lineup_athletes update_lineup_role substitute]

  def show
    @standings = @fixture.tournament_edition.standings
    @events = @fixture.match_events.includes(:club, :athlete).order(:minute, :id)
    @match_stats = @fixture.match_stats.includes(:club).index_by(&:club_id)
    @next_fixture = @career.next_fixture if @fixture.completed?
    @match_state = @fixture.match_state
    @lineups = @fixture.lineups.includes(lineup_athletes: :athlete).for_fixture_order
    @managed_lineup = @fixture.lineup_for(@club)
    @home_lineup = @fixture.lineup_for(@fixture.home_club)
    @away_lineup = @fixture.lineup_for(@fixture.away_club)
    @home_history_fixtures = history_fixtures_for(@fixture.home_club)
    @away_history_fixtures = history_fixtures_for(@fixture.away_club)
    @matchday_session = matchday_session_for(@fixture)
  end

  def simulate
    MatchSimulator.call(@fixture)
    @fixture.match_state&.full_time!
    @career.update!(current_date: @fixture.scheduled_on) if @career.current_date < @fixture.scheduled_on

    redirect_to career_fixture_path(@career, @fixture), notice: "Match simulated."
  end

  def start
    @fixture.in_progress! if @fixture.scheduled?
    @fixture.match_state.running!
    @career.update!(current_date: @fixture.scheduled_on) if @career.current_date < @fixture.scheduled_on

    redirect_to career_fixture_path(@career, @fixture), notice: "Match clock started."
  end

  def pause
    @fixture.match_state.paused! if @fixture.match_state.running?

    redirect_to career_fixture_path(@career, @fixture), notice: "Match paused."
  end

  def resume
    @fixture.match_state.running! if @fixture.match_state.paused?

    redirect_to career_fixture_path(@career, @fixture), notice: "Match resumed."
  end

  def start_matchday
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayEventPlanner.call(session:)
    MatchdayClock.start(session)

    redirect_to career_fixture_path(@career, @fixture), notice: "Matchday clock started."
  end

  def pause_matchday
    session = matchday_session_for(@fixture)
    return redirect_missing_matchday unless session

    session.update!(focused_fixture: @fixture)
    MatchdayClock.pause(session)

    redirect_to career_fixture_path(@career, @fixture), notice: "Matchday paused."
  end

  def resume_matchday
    session = matchday_session_for(@fixture)
    return redirect_missing_matchday unless session

    MatchdayClock.resume(session)

    redirect_to career_fixture_path(@career, @fixture), notice: "Matchday resumed."
  end

  def focus_matchday
    session = matchday_session_for(@fixture)
    return redirect_missing_matchday unless session

    session.update!(focused_fixture: @fixture)
    MatchdayClock.pause(session)

    redirect_to career_fixture_path(@career, @fixture), notice: "Fixture focused."
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
      redirect_to career_fixture_path(@career, @fixture), notice: "Full time."
    else
      AiSubstitutionPlanner.call(fixture: @fixture, club: opponent_club, minute: next_minute)
      redirect_to career_fixture_path(@career, @fixture), notice: "Advanced to #{next_minute}'."
    end
  end

  def tactics
    lineup = @fixture.lineup_for(@club)
    lineup.update!(tactics_params)
    LineupBuilder.call(lineup:) if @fixture.match_state.not_started?

    redirect_to career_fixture_path(@career, @fixture), notice: "Tactics updated."
  end

  def regenerate_lineup
    unless @fixture.match_state.not_started?
      redirect_to career_fixture_path(@career, @fixture), alert: "Lineups can only be regenerated before kickoff."
      return
    end

    LineupBuilder.call(lineup: @fixture.lineup_for(@club))

    redirect_to career_fixture_path(@career, @fixture), notice: "Lineup regenerated."
  end

  def swap_lineup_athletes
    unless @fixture.match_state.not_started?
      redirect_to career_fixture_path(@career, @fixture), alert: "Lineups can only be changed before kickoff."
      return
    end

    LineupSwapper.call(
      lineup: @fixture.lineup_for(@club),
      from_lineup_athlete_id: params.expect(:from_lineup_athlete_id),
      to_lineup_athlete_id: params.expect(:to_lineup_athlete_id)
    )

    redirect_to career_fixture_path(@career, @fixture), notice: "Lineup updated."
  rescue ActiveRecord::RecordNotFound
    redirect_to career_fixture_path(@career, @fixture), alert: "Choose two players from your lineup."
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

    redirect_to career_fixture_path(@career, @fixture), notice: "Tactical role updated."
  rescue ActiveRecord::RecordNotFound
    redirect_to career_fixture_path(@career, @fixture), alert: "Choose one player from your lineup."
  end

  def substitute
    if @fixture.club_substitution_count(@club) >= 5
      redirect_to career_fixture_path(@career, @fixture), alert: "All substitutions have been used."
      return
    end

    lineup = @fixture.lineup_for(@club)
    off = lineup.lineup_athletes.starters.find(params.expect(:off_lineup_athlete_id))
    on = lineup.lineup_athletes.bench.where(substituted_on_minute: nil, substituted_off_minute: nil).find(params.expect(:on_lineup_athlete_id))
    minute = @fixture.match_state.minute

    LineupAthlete.transaction do
      off.update!(starter: false, substituted_off_minute: minute)
      on.update!(starter: true, substituted_on_minute: minute)
      increment_substitution_count!
    end

    redirect_to career_fixture_path(@career, @fixture), notice: "Substitution made."
  rescue ActiveRecord::RecordNotFound
    redirect_to career_fixture_path(@career, @fixture), alert: "Choose one active starter and one unused substitute."
  end

  private

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
    raise ActiveRecord::RecordNotFound unless @fixture.involves?(@club)
  end

  def ensure_match_setup
    @fixture.ensure_match_setup! unless @fixture.completed?
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

  def history_fixtures_for(club)
    Fixture
      .where("home_club_id = :club_id OR away_club_id = :club_id", club_id: club.id)
      .where.not(id: @fixture.id)
      .order(:scheduled_on, :kickoff_minute, :round, :id)
      .limit(8)
  end

  def increment_substitution_count!
    match_state = @fixture.match_state

    if @fixture.home_club_id == @club.id
      match_state.increment!(:home_substitutions)
    else
      match_state.increment!(:away_substitutions)
    end
  end
end
