class StaffContractsController < ApplicationController
  before_action :set_career
  before_action :set_club

  def index
    @contracts = @club.current_staff_contracts.includes(staff_member: :country).order(created_at: :desc)
    @available_staff = StaffMember
      .active
      .includes(:country, :current_staff_contract)
      .where.missing(:current_staff_contract)
      .order(reputation: :desc, last_name: :asc)
      .limit(30)
  end

  def create
    staff_member = StaffMember.find(params.expect(:staff_member_id))
    StaffHiringProcessor.call(
      staff_member:,
      club: @club,
      start_date: @career.current_date,
      wage: params.expect(:wage)
    )

    redirect_to career_staff_contracts_path(@career), notice: "Staff member hired."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to career_staff_contracts_path(@career), alert: error.record.errors.full_messages.to_sentence
  end

  private
    def set_career
      @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
    end

    def set_club
      @club = @career.manager&.current_club
      redirect_to @career, alert: "Take a job before hiring staff." unless @club
    end
end
