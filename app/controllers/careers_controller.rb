class CareersController < ApplicationController
  before_action :set_career, only: %i[show advance rollover]

  def show
    @manager = @career.manager
    @current_contract = @manager&.current_manager_contract
    @next_fixture = @career.next_fixture
    @trophies = @manager&.trophies&.includes(:club, :tournament_edition)&.order(won_on: :desc) || []
    @manager_season_stats = @manager&.manager_season_stats&.includes(:club, :tournament_edition)&.order(created_at: :desc) || []
    @manager_totals = manager_totals(@manager_season_stats)
    @available_clubs = available_clubs_for(@manager) if @manager&.unemployed?
    @rollover_candidate = @career.rollover_candidate if @current_contract && @next_fixture.nil?
  end

  def advance
    fixture = @career.next_fixture

    if fixture
      @career.update!(current_date: fixture.scheduled_on)
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

    def available_clubs_for(manager)
      return Club.none unless manager

      Club.active
        .includes(:country, :club_finance)
        .left_outer_joins(:current_manager_contract)
        .where(manager_contracts: { id: nil })
        .where(reputation: ..manager.job_reputation_ceiling)
        .order(:reputation, :name)
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
end
