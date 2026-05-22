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
  end

  private
    def set_career
      @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
    end

    def set_club
      @club = @career.manager&.current_club
      redirect_to @career, alert: "Take a job before opening a club dashboard." unless @club
    end
end
