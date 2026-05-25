# frozen_string_literal: true

class TournamentsController < ApplicationController
  before_action :set_career

  def index
    @countries = Country.active.order(:name)
    @country = Country.find_by(id: params[:country_id])
    @tournaments = Tournament.includes(:country, :tournament_editions).active.order(:name)
    @tournaments = @tournaments.where(country: @country) if @country
  end

  def show
    @tournament = Tournament.includes(:country).find(params.expect(:id))
    @editions = @tournament.tournament_editions.includes(:champion).order(season_year: :desc)
    @current_edition = @editions.first
    @standings = @current_edition&.standings || []
    @fixtures = @current_edition&.fixtures&.includes(:home_club, :away_club)&.order(:scheduled_on, :round)&.limit(30) || []
  end

  private

  def set_career
    @career = Current.user.careers.includes(:manager).find(params.expect(:career_id))
  end
end
