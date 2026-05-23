class Career < ApplicationRecord
  enum :status, { active: 0, retired: 1, archived: 2 }

  belongs_to :user
  has_one :manager, dependent: :destroy

  validates :name, presence: true
  validates :current_date, presence: true

  def next_fixture
    club = manager&.current_club
    return unless club

    Fixture
      .scheduled
      .where("scheduled_on >= :current_date", current_date:)
      .where("home_club_id = :club_id OR away_club_id = :club_id", club_id: club.id)
      .order(:scheduled_on, :kickoff_minute, :round)
      .first
  end

  def rollover_candidate
    club = manager&.current_club
    return if club.nil? || next_fixture

    TournamentEdition
      .completed
      .joins(:tournament_participations)
      .where(tournament_participations: { club_id: club.id })
      .order(season_year: :desc, ends_on: :desc)
      .first
  end
end
