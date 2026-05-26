# frozen_string_literal: true

module DataImport
  class ClubsImporter < BaseImporter
    def call
      records = rows.map do |row|
        country = find_country(row.fetch(:country_external_id))
        Club.find_or_initialize_by(external_identity(row)).tap do |club|
          club.country = country
          club.name = row.fetch(:name)
          club.short_name = row.fetch(:short_name)
          club.reputation = row.fetch(:reputation, 5)
          club.founded_year = row[:founded_year]
          club.international = row.fetch(:international, false)
          club.status = row.fetch(:status, :active)
          club.save!
          club.create_club_finance! unless club.club_finance
        end
      end

      finish_with(records)
    rescue StandardError => e
      import_run.fail!(notes: e.message)
      raise
    end

    private

    def find_country(external_id)
      Country.find_by!(external_source: source, external_id: external_id.to_s)
    end
  end
end
