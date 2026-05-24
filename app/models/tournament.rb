# frozen_string_literal: true

class Tournament < ApplicationRecord
  enum :scope, { domestic: 0, international: 1 }
  enum :format, { league: 0, cup: 1, mixed: 2 }
  enum :status, { active: 0, inactive: 1, archived: 2 }

  belongs_to :country
  has_many :tournament_editions, dependent: :destroy

  validates :name, :short_name, presence: true
  validates :name, uniqueness: { scope: :country_id }
end
