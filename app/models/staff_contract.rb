# frozen_string_literal: true

class StaffContract < ApplicationRecord
  enum :status, { active: 0, expired: 1, terminated: 2 }

  belongs_to :staff_member
  belongs_to :club

  validates :start_date, presence: true
  validates :wage, numericality: { greater_than_or_equal_to: 0 }
end
