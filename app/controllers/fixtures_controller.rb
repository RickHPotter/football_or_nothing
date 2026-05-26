# frozen_string_literal: true

class FixturesController < ApplicationController
  before_action :set_career
  before_action :set_club
  before_action :set_fixture
  before_action :ensure_match_setup, only: %i[show simulate start pause resume advance_clock tactics regenerate_lineup substitute]

  def show
    @standings = @fixture.tournament_edition.standings
    @events = @fixture.match_events.includes(:club, :athlete).order(:minute, :id)
    @match_stats = @fixture.match_stats.includes(:club).index_by(&:club_id)
    @next_fixture = @career.next_fixture if @fixture.completed?
    @match_state = @fixture.match_state
    @lineups = @fixture.lineups.includes(lineup_athletes: :athlete).for_fixture_order
    @managed_lineup = @fixture.lineup_for(@club)
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

  def increment_substitution_count!
    match_state = @fixture.match_state

    if @fixture.home_club_id == @club.id
      match_state.increment!(:home_substitutions)
    else
      match_state.increment!(:away_substitutions)
    end
  end
end
