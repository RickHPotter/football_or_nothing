# frozen_string_literal: true

module DataImport
  class CountriesImporter < BaseImporter
    def call
      records = rows.map do |row|
        Country.find_or_initialize_by(external_identity(row)).tap do |country|
          country.name = row.fetch(:name)
          country.code = row.fetch(:code)
          country.reputation = row.fetch(:reputation, 5)
          country.status = row.fetch(:status, :active)
          country.save!
        end
      end

      finish_with(records)
    rescue StandardError => e
      import_run.fail!(notes: e.message)
      raise
    end
  end
end
