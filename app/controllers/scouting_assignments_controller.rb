class ScoutingAssignmentsController < ApplicationController
  before_action :set_career
  before_action :set_club

  def index
    @assignment = @club.scouting_assignments.build(starts_on: @career.current_date, ends_on: @career.current_date + 14.days)
    @assignments = @club.scouting_assignments.includes(:country).order(created_at: :desc).limit(20)
    @reports = @club.scout_reports.includes(athlete: :country).order(created_on: :desc, created_at: :desc).limit(20)
    @countries = Country.active.order(:name)
  end

  def create
    @club.scouting_assignments.create!(
      scouting_assignment_params.merge(
        starts_on: @career.current_date,
        ends_on: @career.current_date + 14.days,
        status: :active
      )
    )

    redirect_to career_scouting_assignments_path(@career), notice: "Scouting assignment started."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to career_scouting_assignments_path(@career), alert: error.record.errors.full_messages.to_sentence
  end

  private
    def set_career
      @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
    end

    def set_club
      @club = @career.manager&.current_club
      redirect_to @career, alert: "Take a job before scouting players." unless @club
    end

    def scouting_assignment_params
      params.expect(scouting_assignment: %i[country_id position focus])
    end
end
