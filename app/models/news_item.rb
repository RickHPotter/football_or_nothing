class NewsItem < ApplicationRecord
  enum :category, {
    match: 0,
    transfer: 1,
    injury: 2,
    discipline: 3,
    trophy: 4,
    contract: 5,
    youth: 6,
    world: 7
  }

  belongs_to :career, optional: true
  belongs_to :club, optional: true
  belongs_to :athlete, optional: true
  belongs_to :manager, optional: true
  belongs_to :tournament_edition, optional: true

  validates :title, :occurred_on, presence: true

  scope :recent, -> { order(occurred_on: :desc, created_at: :desc) }
end
