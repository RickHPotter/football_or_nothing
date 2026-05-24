# frozen_string_literal: true

module DataImport
  class AthletesImporter < BaseImporter
    def call
      records = rows.map do |row|
        country = find_country(row.fetch(:country_external_id))
        Athlete.find_or_initialize_by(external_identity(row)).tap do |athlete|
          athlete.country = country
          athlete.first_name = row.fetch(:first_name)
          athlete.last_name = row.fetch(:last_name)
          athlete.birthdate = row[:birthdate]
          athlete.position = row.fetch(:position, :central_midfielder)
          athlete.preferred_foot = row.fetch(:preferred_foot, :right)
          athlete.current_ability = row.fetch(:current_ability, 5)
          athlete.potential_ability = row.fetch(:potential_ability, athlete.current_ability)
          athlete.reputation = row.fetch(:reputation, 1)
          athlete.morale = row.fetch(:morale, 50)
          athlete.condition = row.fetch(:condition, 100)
          assign_attributes(athlete, row)
          athlete.save!
        end
      end

      finish_with(records)
    rescue StandardError => error
      import_run.fail!(notes: error.message)
      raise
    end

    private

    def find_country(external_id)
      Country.find_by!(external_source: source, external_id: external_id.to_s)
    end

    def assign_attributes(athlete, row)
      Athlete::ATTRIBUTES.each do |attribute|
        athlete.public_send("#{attribute}=", row.fetch(attribute, athlete.current_ability))
      end
    end
  end
end
