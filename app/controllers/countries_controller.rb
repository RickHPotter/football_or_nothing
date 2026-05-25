# frozen_string_literal: true

class CountriesController < ApplicationController
  before_action :set_career

  def index
    @countries = Country.active.order(:name)
    @club_counts = Club.group(:country_id).count
    @tournament_counts = Tournament.group(:country_id).count
  end

  def show
    @country = Country.active.find(params.expect(:id))
    @clubs = @country.clubs.active.includes(:club_finance).order(:reputation, :name).limit(100)
    @tournaments = @country.tournaments.includes(:tournament_editions).order(:name)
    @recent_editions = TournamentEdition
                       .includes(:tournament, :champion)
                       .joins(:tournament)
                       .where(tournaments: { country_id: @country.id })
                       .order(starts_on: :desc)
                       .limit(10)
  end

  private

  def set_career
    @career = Current.user.careers.includes(:manager).find(params.expect(:career_id))
  end
end
