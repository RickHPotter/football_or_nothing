# frozen_string_literal: true

class YouthIntakesController < ApplicationController
  before_action :set_career
  before_action :set_club

  def index
    @intakes = @club.youth_intakes.includes(:athletes).order(season_year: :desc)
    @current_intake = @intakes.first
  end

  def create
    YouthIntakeGenerator.call(
      club: @club,
      season_year: @career.current_date.year,
      generated_on: @career.current_date
    )

    redirect_to career_youth_intakes_path(@career), notice: "Youth intake generated."
  end

  def promote
    athlete = Athlete.find(params.expect(:athlete_id))
    YouthPromotionProcessor.call(
      athlete:,
      club: @club,
      promotion_date: @career.current_date,
      wage: params[:wage].presence || 100
    )

    redirect_to career_youth_intakes_path(@career), notice: "Player promoted to the senior squad."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to career_youth_intakes_path(@career), alert: e.record.errors.full_messages.to_sentence
  end

  private

  def set_career
    @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
  end

  def set_club
    @club = @career.manager&.current_club
    redirect_to @career, alert: "Take a job before using the youth academy." unless @club
  end
end
