class TournamentEdition < ApplicationRecord
  enum :status, { scheduled: 0, in_progress: 1, completed: 2, archived: 3 }

  belongs_to :tournament
  belongs_to :champion, class_name: "Club", optional: true
  has_many :tournament_participations, dependent: :destroy
  has_many :clubs, through: :tournament_participations
  has_many :fixtures, dependent: :destroy

  validates :season_year, :name, :starts_on, :ends_on, presence: true
  validates :season_year, uniqueness: { scope: :tournament_id }
end
