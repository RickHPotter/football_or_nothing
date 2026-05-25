# frozen_string_literal: true

class CareersController < ApplicationController
  before_action :set_career, only: %i[show advance rollover]

  def show
    @manager = @career.manager
    @current_contract = @manager&.current_manager_contract
    @next_fixture = @career.next_fixture
    @trophies = @manager&.trophies&.includes(:club, :tournament_edition)&.order(won_on: :desc) || []
    @manager_season_stats = @manager&.manager_season_stats&.includes(:club, :tournament_edition)&.order(created_at: :desc) || []
    @manager_totals = manager_totals(@manager_season_stats)
    @news_items = news_items_for(@manager&.current_club)
    @international_editions = international_editions
    if @manager&.unemployed?
      @job_countries = Country.active.order(:name)
      @job_country = job_country_for(@manager)
      @available_clubs = available_clubs_for(@manager, country: @job_country)
      @club_divisions = club_divisions_for(@available_clubs)
    end
    @rollover_candidate = @career.rollover_candidate if @current_contract && @next_fixture.nil?
  end

  def advance
    fixture = @career.next_fixture

    if fixture
      current_date = @career.current_date
      @career.update!(current_date: fixture.scheduled_on)
      apply_training(current_date, fixture.scheduled_on)
      process_scouting(fixture.scheduled_on)
      redirect_to career_fixture_path(@career, fixture), notice: "Advanced to match day."
    else
      redirect_to @career, alert: "No upcoming fixtures are scheduled."
    end
  end

  def rollover
    candidate = @career.rollover_candidate

    unless candidate
      redirect_to @career, alert: "No completed season is ready for rollover."
      return
    end

    SeasonRollover.call(candidate)
    fixture = @career.next_fixture
    @career.update!(current_date: fixture.scheduled_on) if fixture

    redirect_to @career, notice: "Next season started."
  end

  def new
    @career = Current.user.careers.build(default_career_attributes)
    @manager = @career.build_manager
    @countries = Country.active.order(:name)
  end

  def create
    @career = Current.user.careers.build(career_params)
    @career.current_date ||= Date.new(2026, 1, 1)
    @manager = @career.build_manager(manager_params.merge(user: Current.user, reputation: 1, status: :unemployed))

    if @career.save
      redirect_to @career, notice: "Manager career created."
    else
      @countries = Country.active.order(:name)
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_career
    @career = Current.user.careers.includes(manager: [ :country, { current_manager_contract: { club: :club_finance } } ]).find(params[:id])
  end

  def default_career_attributes
    { name: "Manager Career", current_date: Date.new(2026, 1, 1) }
  end

  def career_params
    params.expect(career: %i[name current_date])
  end

  def manager_params
    params.expect(manager: %i[first_name last_name birthdate country_id])
  end

  def available_clubs_for(manager, country: nil)
    return Club.none unless manager

    clubs = Club.active
                .includes(:country, :club_finance, crest_attachment: :blob)
                .left_outer_joins(:current_manager_contract)
                .where(manager_contracts: { id: nil })
    clubs = clubs.where(country:) if country

    clubs.order(:reputation, :name)
         .limit(80)
  end

  def job_country_for(manager)
    return Country.find_by(id: params[:country_id]) if params[:country_id].present?

    manager.country
  end

  def club_divisions_for(clubs)
    latest_participations = TournamentParticipation
                            .includes(tournament_edition: :tournament)
                            .where(club_id: clubs.map(&:id))
                            .sort_by { |participation| [ -participation.tournament_edition.season_year, participation.tournament_edition.name ] }

    latest_participations.each_with_object({}) do |participation, divisions|
      divisions[participation.club_id] ||= participation.tournament_edition
    end
  end

  def international_editions
    TournamentEdition
      .includes(:tournament, :champion)
      .joins(:tournament)
      .where(tournaments: { scope: Tournament.scopes[:international] })
      .order(starts_on: :desc)
      .limit(5)
  end

  def manager_totals(stats)
    {
      matches: stats.sum(&:matches),
      wins: stats.sum(&:wins),
      draws: stats.sum(&:draws),
      losses: stats.sum(&:losses),
      trophies: stats.sum(&:trophies)
    }
  end

  def news_items_for(club)
    return NewsItem.none unless club

    NewsItem.includes(:club, :athlete, :manager, :tournament_edition)
            .where(club_id: [ nil, club.id ])
            .recent
            .limit(10)
  end

  def apply_training(from_date, to_date)
    return unless @career.manager&.current_club

    TrainingApplier.call(
      club: @career.manager.current_club,
      manager: @career.manager,
      from_date:,
      to_date:
    )
  end

  def process_scouting(date)
    return unless @career.manager&.current_club

    ScoutingAssignmentProcessor.call(club: @career.manager.current_club, date:)
  end
end
