class AthletesController < ApplicationController
  before_action :set_career
  before_action :set_club
  before_action :set_athlete

  def show
    @contract = @athlete.current_athlete_contract
  end

  private
    def set_career
      @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
    end

    def set_club
      @club = @career.manager&.current_club
      redirect_to @career, alert: "Take a job before opening athlete profiles." unless @club
    end

    def set_athlete
      @athlete = @club.current_athletes.includes(:country, :current_athlete_contract).find(params.expect(:id))
    end
end
