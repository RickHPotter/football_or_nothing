class FixturesController < ApplicationController
  before_action :set_career
  before_action :set_club
  before_action :set_fixture

  def show
    @standings = @fixture.tournament_edition.standings
    @events = @fixture.match_events.includes(:club, :athlete).order(:minute, :id)
    @next_fixture = @career.next_fixture if @fixture.completed?
  end

  def simulate
    MatchSimulator.call(@fixture)
    @career.update!(current_date: @fixture.scheduled_on) if @career.current_date < @fixture.scheduled_on

    redirect_to career_fixture_path(@career, @fixture), notice: "Match simulated."
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
      @fixture = Fixture.includes(:home_club, :away_club, :stadium, :match_events, tournament_edition: [ :tournament, { tournament_participations: :club } ]).find(params.expect(:id))
      raise ActiveRecord::RecordNotFound unless @fixture.involves?(@club)
    end
end
