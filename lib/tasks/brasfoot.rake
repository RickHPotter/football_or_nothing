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

  desc "Print one Brasfoot league config. Usage: bin/rails brasfoot:league_config[/path/to/BRA.cfg]"
  task :league_config, [ :path ] => :environment do |_task, args|
    path = args[:path] || ENV.fetch("BRASFOOT_CONFIG")
    config = DataImport::Brasfoot::LeagueConfigParser.call(path)

    puts "[brasfoot] #{config.kind} config #{config.name}"
    config.divisions.each do |division|
      puts [
        "division=#{division.division}",
        "name=#{division.name}",
        "teams=#{division.team_count}",
        "relegated=#{division.relegated_count}",
        "format=#{division.format}"
      ].join(" | ")
    end
  end

  desc "Inspect one Brasfoot team against nearby tournament configs. Usage: bin/rails brasfoot:debug_team[/path/to/flarj.ban]"
  task :debug_team, [ :path ] => :environment do |_task, args|
    path = args[:path] || ENV.fetch("BRASFOOT_FILE")
    report = DataImport::Brasfoot::TeamTournamentProbe.call(team_path: path)

    puts "[brasfoot] team=#{report.team.name} file=#{report.team.external_id}"
    puts "[brasfoot] suffix=#{report.country_suffix}"
    puts "[brasfoot] candidate national division field n=#{report.candidate_national_division}"
    puts "[brasfoot] candidate state division field o=#{report.candidate_state_division}"
    puts "[brasfoot] raw team fields=#{report.raw_team_fields.inspect}"

    if report.national_config
      puts "[brasfoot] national config=#{report.national_config.name}"
      report.national_config.divisions.each do |division|
        puts "  - #{division.name}: division=#{division.division}, teams=#{division.team_count}"
      end
    end

    if report.state_config
      puts "[brasfoot] state config=#{report.state_config.name}"
      report.state_config.divisions.each do |division|
        puts "  - #{division.name}: division=#{division.division}, teams=#{division.team_count}"
      end
    end
  end

  desc "Print proposed team membership for one Brasfoot league config. Usage: bin/rails brasfoot:plan_memberships[/path/to/BRA.cfg]"
  task :plan_memberships, [ :path ] => :environment do |_task, args|
    path = args[:path] || ENV.fetch("BRASFOOT_CONFIG")
    teams_path = ENV.fetch("BRASFOOT_TEAMS_PATH", "/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026/teams")
    plan = DataImport::Brasfoot::LeagueMembershipPlanner.call(config_path: path, teams_path:)

    plan.each do |planned_division|
      puts "[brasfoot] #{planned_division.division.name}"
      planned_division.teams.each_with_index do |team, index|
        fields = team.ranking_fields
        puts [
          index + 1,
          team.external_id,
          team.name,
          "n=#{fields["n"]}",
          "c=#{fields["c"]}",
          "o=#{fields["o"]}",
          "g=#{fields["g"]}"
        ].join(" | ")
      end
    end
  end
end
