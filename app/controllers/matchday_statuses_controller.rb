# frozen_string_literal: true

class MatchdayStatusesController < ApplicationController
  before_action :set_career
  before_action :set_club
  before_action :set_fixture
  before_action :set_matchday_session

  def show
    MatchdayClock.refresh(@matchday_session)
    LiveMatchEventApplier.call(session: @matchday_session)
    MatchdaySessionFinalizer.call(session: @matchday_session, focused_fixture: @fixture)

    render json: MatchdayStatusPayload.call(@matchday_session)
  end

  private

  def set_career
    @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
  end

  def set_club
    @club = @career.manager&.current_club
    head :not_found unless @club
  end

  def set_fixture
    @fixture = Fixture.includes(:home_club, :away_club, :stadium).find(params.expect(:id))
  end

  def set_matchday_session
    @matchday_session = MatchdaySession.find_by!(
      career: @career,
      tournament_edition: @fixture.tournament_edition,
      scheduled_on: @fixture.scheduled_on,
      round: @fixture.round
    )
    raise ActiveRecord::RecordNotFound unless @fixture.involves?(@club) || @matchday_session.includes_fixture?(@fixture)
  end
end
