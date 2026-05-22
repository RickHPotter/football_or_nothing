class CareersController < ApplicationController
  before_action :set_career, only: :show

  def show
  end

  def new
    @career = Current.user.careers.build(default_career_attributes)
    @manager = @career.build_manager
    @countries = Country.active.order(:name)
  end

  def create
    @career = Current.user.careers.build(career_params)
    @career.current_date ||= Date.new(2026, 1, 1)
    @manager = @career.build_manager(manager_params.merge(user: Current.user, reputation: 1))

    if @career.save
      redirect_to @career, notice: "Manager career created."
    else
      @countries = Country.active.order(:name)
      render :new, status: :unprocessable_content
    end
  end

  private
    def set_career
      @career = Current.user.careers.includes(manager: :country).find(params[:id])
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
end
