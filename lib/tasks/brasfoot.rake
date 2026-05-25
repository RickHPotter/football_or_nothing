# frozen_string_literal: true

namespace :brasfoot do
  desc "Import Brasfoot .ban team files. Usage: BRASFOOT_TEAMS_PATH=/path/to/teams bin/rails brasfoot:import"
  task import: :environment do
    path = ENV.fetch("BRASFOOT_TEAMS_PATH", "/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026/teams")
    limit = ENV["BRASFOOT_LIMIT"]
    source = ENV.fetch("BRASFOOT_SOURCE", DataImport::Brasfoot::PackImporter::DEFAULT_SOURCE)
    country_name = ENV.fetch("BRASFOOT_COUNTRY_NAME", DataImport::Brasfoot::PackImporter::DEFAULT_COUNTRY_NAME)
    country_code = ENV.fetch("BRASFOOT_COUNTRY_CODE", DataImport::Brasfoot::PackImporter::DEFAULT_COUNTRY_CODE)

    DataImport::Brasfoot::PackImporter.call(
      path:,
      source:,
      country_name:,
      country_code:,
      limit:
    )

    puts "[brasfoot] imported #{Club.where(external_source: source).count} clubs"
    puts "[brasfoot] imported #{Athlete.where(external_source: source).count} athletes"
  end

  desc "Import one Brasfoot .ban file. Usage: bin/rails brasfoot:file[/path/to/flarj.ban]"
  task :file, [ :path ] => :environment do |_task, args|
    path = args[:path] || ENV.fetch("BRASFOOT_FILE")
    source = ENV.fetch("BRASFOOT_SOURCE", DataImport::Brasfoot::PackImporter::DEFAULT_SOURCE)

    DataImport::Brasfoot::PackImporter.call(path:, source:)
    club = Club.find_by!(external_source: source, external_id: Pathname(path).basename(".ban").to_s)

    puts "[brasfoot] imported #{club.name} (#{club.country.name})"
    puts "[brasfoot] athletes #{club.current_athletes.count}"
  end
end
