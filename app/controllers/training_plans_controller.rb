# frozen_string_literal: true

class TrainingPlansController < ApplicationController
  before_action :set_career
  before_action :set_club

  def update
    training_plan.update!(training_plan_params.merge(manager: @career.manager, active_from: @career.current_date))

    redirect_to career_club_path(@career), notice: "Training plan updated."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to career_club_path(@career), alert: e.record.errors.full_messages.to_sentence
  end

  private

  def set_career
    @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
  end

  def set_club
    @club = @career.manager&.current_club
    redirect_to @career, alert: "Take a job before changing training." unless @club
  end

  def training_plan
    @training_plan ||= @club.training_plan || @club.build_training_plan(
      manager: @career.manager,
      focus: :balanced,
      intensity: :normal,
      active_from: @career.current_date
    )
  end

  def training_plan_params
    params.expect(training_plan: %i[focus intensity])
  end
end
