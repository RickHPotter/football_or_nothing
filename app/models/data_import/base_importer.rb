# frozen_string_literal: true

module DataImport
  class BaseImporter
    def self.call(...)
      new(...).call
    end

    def initialize(source:, rows:)
      @source = source
      @rows = rows
    end

    private

    attr_reader :source, :rows

    def import_run
      @import_run ||= DataImportRun.create!(source:, started_at: Time.current)
    end

    def external_identity(row)
      {
        external_source: source,
        external_id: row.fetch(:external_id).to_s
      }
    end

    def finish_with(records)
      import_run.complete!(records_processed: records.length)
      records
    end
  end
end
