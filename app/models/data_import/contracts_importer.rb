# frozen_string_literal: true

module DataImport
  class ContractsImporter < BaseImporter
    def call
      records = rows.map do |row|
        AthleteContract.find_or_initialize_by(external_identity(row)).tap do |contract|
          contract.athlete = athlete_for(row)
          contract.club = club_for(row)
          contract.start_date = row.fetch(:start_date)
          contract.end_date = row[:end_date]
          contract.wage = row.fetch(:wage, 0)
          contract.release_clause = row[:release_clause]
          contract.current = row.fetch(:current, true)
          contract.status = row.fetch(:status, :active)
          contract.save!
        end
      end

      finish_with(records)
    rescue StandardError => error
      import_run.fail!(notes: error.message)
      raise
    end

    private

    def athlete_for(row)
      Athlete.find_by!(external_source: source, external_id: row.fetch(:athlete_external_id).to_s)
    end

    def club_for(row)
      Club.find_by!(external_source: source, external_id: row.fetch(:club_external_id).to_s)
    end
  end
end
