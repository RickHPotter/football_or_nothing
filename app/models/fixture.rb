class Fixture < ApplicationRecord
  enum :status, { scheduled: 0, in_progress: 1, completed: 2, postponed: 3, cancelled: 4 }

  belongs_to :tournament_edition
  belongs_to :home_club, class_name: "Club"
  belongs_to :away_club, class_name: "Club"
  belongs_to :stadium

  validates :scheduled_on, :round, presence: true
  validates :kickoff_minute, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 1440 }
  validates :home_club_id, uniqueness: { scope: %i[tournament_edition_id away_club_id] }
  validate :clubs_must_differ

  private
    def clubs_must_differ
      errors.add(:away_club, "must differ from home club") if home_club_id == away_club_id
    end
end
