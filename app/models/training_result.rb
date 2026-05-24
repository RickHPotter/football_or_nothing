# frozen_string_literal: true

class TrainingResult < ApplicationRecord
  belongs_to :training_plan
  belongs_to :club
  belongs_to :athlete

  validates :occurred_on, :attribute_name, :old_value, :new_value, presence: true
  validates :condition_change, numericality: { only_integer: true }
end
