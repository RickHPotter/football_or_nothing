# frozen_string_literal: true

class ManagerContractsController < ApplicationController
  before_action :set_career
  before_action :set_manager

  def create
    club = available_clubs.find(params.expect(:club_id))

    ManagerContract.transaction do
      @manager.manager_contracts.create!(
        club:,
        start_date: @career.current_date,
        wage: starting_wage_for(club),
        role: :head_coach,
        status: :active,
        current: true,
        expectations: "Build the club patiently and improve league position."
      )
      @manager.active!
    end

    redirect_to @career, notice: "You signed with #{club.name}."
  rescue ActiveRecord::RecordNotFound
    redirect_to @career, alert: "That club is not available for this manager."
  end

  private

  def set_career
    @career = Current.user.careers.find(params.expect(:career_id))
  end

  def set_manager
    @manager = @career.manager
  end

  def available_clubs
    Club.active
        .left_outer_joins(:current_manager_contract)
        .where(manager_contracts: { id: nil })
        .where(reputation: ..@manager.job_reputation_ceiling)
  end

  def starting_wage_for(club)
    5_000 + (club.reputation * 1_000)
  end
end
