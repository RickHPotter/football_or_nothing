class HomeController < ApplicationController
  def index
    @career = Current.user.careers.includes(:manager).order(created_at: :desc).first
  end
end
