# frozen_string_literal: true

class ScoutingAssignment < ApplicationRecord
  enum :focus, { general: 0, first_team: 1, youth: 2, bargain: 3 }
  enum :status, { active: 0, completed: 1, cancelled: 2 }
  enum :position, Athlete.defined_enums.fetch("position").transform_values(&:to_i), prefix: true

  belongs_to :club
  belongs_to :country, optional: true
  has_many :scout_reports, dependent: :destroy

  validates :starts_on, :ends_on, presence: true
  validate :ends_on_must_follow_start

  private

  def ends_on_must_follow_start
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, "must be after start date") if ends_on <= starts_on
  end
end
