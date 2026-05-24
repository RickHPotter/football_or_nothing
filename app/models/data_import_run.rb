# frozen_string_literal: true

class DataImportRun < ApplicationRecord
  enum :status, { running: 0, completed: 1, failed: 2 }

  validates :source, :started_at, presence: true
  validates :records_processed, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def complete!(records_processed:)
    update!(status: :completed, records_processed:, finished_at: Time.current)
  end

  def fail!(notes:)
    update!(status: :failed, notes:, finished_at: Time.current)
  end
end
