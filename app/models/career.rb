class Career < ApplicationRecord
  enum :status, { active: 0, retired: 1, archived: 2 }

  belongs_to :user
  has_one :manager, dependent: :destroy

  validates :name, presence: true
  validates :current_date, presence: true
end
