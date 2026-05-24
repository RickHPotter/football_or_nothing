class ClubsController < ApplicationController
  before_action :set_career
  before_action :set_club

  def show
    @finance = @club.club_finance
    @stadium = @club.stadiums.order(:created_at).first
    @contracts = @club.current_athlete_contracts.includes(athlete: :country).order(:squad_number)
    @fixtures = Fixture
      .includes(:tournament_edition, :home_club, :away_club)
      .where("home_club_id = :club_id OR away_club_id = :club_id", club_id: @club.id)
      .order(:scheduled_on, :kickoff_minute, :round)
      .limit(10)
    @current_participation = @club.tournament_participations.includes(:tournament_edition).order(created_at: :desc).first
    @standings = @current_participation&.tournament_edition&.standings || []
    @trophies = @club.trophies.includes(:tournament_edition, :manager).order(won_on: :desc)
    @club_season_stats = @club.club_season_stats.includes(:tournament_edition).order(created_at: :desc)
    @top_scorers = top_scorers_for(@current_participation&.tournament_edition)
    @training_plan = @club.training_plan || @club.build_training_plan(
      manager: @career.manager,
      focus: :balanced,
      intensity: :normal,
      active_from: @career.current_date
    )
    @training_results = @club.training_results.includes(:athlete).order(occurred_on: :desc, created_at: :desc).limit(6)
    @latest_youth_intake = @club.youth_intakes.includes(:athletes).order(season_year: :desc).first
    @news_items = @club.news_items.recent.limit(6)
  end

  private
    def set_career
      @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
    end

    def set_club
      @club = @career.manager&.current_club
      redirect_to @career, alert: "Take a job before opening a club dashboard." unless @club
    end

    def top_scorers_for(tournament_edition)
      return [] unless tournament_edition

      @club.athlete_season_stats
        .includes(:athlete)
        .where(tournament_edition:)
        .where("goals > 0")
        .order(goals: :desc, appearances: :asc)
        .limit(5)
    end
end
