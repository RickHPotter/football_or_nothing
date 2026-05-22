class Trophy < ApplicationRecord
  belongs_to :tournament_edition
  belongs_to :club
  belongs_to :manager, optional: true

  validates :name, :won_on, presence: true
  validates :club_id, uniqueness: { scope: :tournament_edition_id }
end
