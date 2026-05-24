# frozen_string_literal: true

class NewsPublisher
  def self.call(...)
    new(...).call
  end

  def initialize(category:, title:, occurred_on:, body: nil, career: nil, club: nil, athlete: nil, manager: nil, tournament_edition: nil)
    @category = category
    @title = title
    @body = body
    @occurred_on = occurred_on
    @career = career
    @club = club
    @athlete = athlete
    @manager = manager
    @tournament_edition = tournament_edition
  end

  def call
    NewsItem.find_or_create_by!(
      category:,
      title:,
      occurred_on:,
      club:,
      athlete:,
      manager:,
      tournament_edition:
    ) do |item|
      item.career = career
      item.body = body
    end
  end

  private

  attr_reader :category, :title, :body, :occurred_on, :career, :club, :athlete, :manager, :tournament_edition
end
