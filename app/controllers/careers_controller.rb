class CareersController < ApplicationController
  before_action :set_career, only: :show

  def show
    @manager = @career.manager
    @current_contract = @manager&.current_manager_contract
    @available_clubs = available_clubs_for(@manager) if @manager&.unemployed?
  end

  def new
    @career = Current.user.careers.build(default_career_attributes)
    @manager = @career.build_manager
    @countries = Country.active.order(:name)
  end

  def create
    @career = Current.user.careers.build(career_params)
    @career.current_date ||= Date.new(2026, 1, 1)
    @manager = @career.build_manager(manager_params.merge(user: Current.user, reputation: 1, status: :unemployed))

    if @career.save
      redirect_to @career, notice: "Manager career created."
    else
      @countries = Country.active.order(:name)
      render :new, status: :unprocessable_content
    end
  end

  private
    def set_career
      @career = Current.user.careers.includes(manager: [ :country, { current_manager_contract: { club: :club_finance } } ]).find(params[:id])
    end

    def default_career_attributes
      { name: "Manager Career", current_date: Date.new(2026, 1, 1) }
    end

    def career_params
      params.expect(career: %i[name current_date])
    end

    def manager_params
      params.expect(manager: %i[first_name last_name birthdate country_id])
    end

    def available_clubs_for(manager)
      return Club.none unless manager

      Club.active
        .includes(:country, :club_finance)
        .left_outer_joins(:current_manager_contract)
        .where(manager_contracts: { id: nil })
        .where(reputation: ..manager.reputation + 5)
        .order(:reputation, :name)
    end
end
