# frozen_string_literal: true

namespace :brasfoot do
  DEFAULT_PACK_PATH = "/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026"

  desc "Import Brasfoot .ban team files and configured leagues. Usage: BRASFOOT_PACK_PATH=/path/to/pack bin/rails brasfoot:import"
  task import: :environment do
    pack_path = Pathname(ENV.fetch("BRASFOOT_PACK_PATH", DEFAULT_PACK_PATH))
    path = ENV.fetch("BRASFOOT_TEAMS_PATH", pack_path.join("teams").to_s)
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

    unless ActiveModel::Type::Boolean.new.cast(ENV.fetch("BRASFOOT_SKIP_ASSETS", false))
      DataImport::Brasfoot::ClubAssetImporter.call(teams_path: path, club_source: source)
      puts "[brasfoot] imported club visual assets"
    end

    unless ActiveModel::Type::Boolean.new.cast(ENV.fetch("BRASFOOT_SKIP_LEAGUES", false))
      league_configs(pack_path).each do |config_path|
        editions = DataImport::Brasfoot::LeagueImporter.call(
          config_path:,
          teams_path: path,
          club_source: source,
          season_year: ENV.fetch("BRASFOOT_SEASON_YEAR", DataImport::Brasfoot::LeagueImporter::DEFAULT_SEASON_YEAR)
        )

        puts "[brasfoot] imported league #{config_path.basename}: #{editions.map(&:name).join(", ")}"
      end
    end
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

  desc "Import one Brasfoot league config. Usage: bin/rails brasfoot:import_league[/path/to/BRA.cfg]"
  task :import_league, [ :path ] => :environment do |_task, args|
    path = args[:path] || ENV.fetch("BRASFOOT_CONFIG")
    teams_path = ENV.fetch("BRASFOOT_TEAMS_PATH", Pathname(path).dirname.join("..", "teams").cleanpath.to_s)
    source = ENV.fetch("BRASFOOT_SOURCE", DataImport::Brasfoot::PackImporter::DEFAULT_SOURCE)
    season_year = ENV.fetch("BRASFOOT_SEASON_YEAR", DataImport::Brasfoot::LeagueImporter::DEFAULT_SEASON_YEAR)

    editions = DataImport::Brasfoot::LeagueImporter.call(
      config_path: path,
      teams_path:,
      club_source: source,
      season_year:
    )

    editions.each do |edition|
      puts "[brasfoot] imported #{edition.name}: #{edition.clubs.count} clubs, #{edition.fixtures.count} fixtures"
    end
  end

  desc "Import Brasfoot club visual assets from teams subdirectories"
  task assets: :environment do
    pack_path = Pathname(ENV.fetch("BRASFOOT_PACK_PATH", DEFAULT_PACK_PATH))
    teams_path = ENV.fetch("BRASFOOT_TEAMS_PATH", pack_path.join("teams").to_s)
    source = ENV.fetch("BRASFOOT_SOURCE", DataImport::Brasfoot::PackImporter::DEFAULT_SOURCE)

    DataImport::Brasfoot::ClubAssetImporter.call(teams_path:, club_source: source)
    puts "[brasfoot] imported club visual assets"
  end

  def league_configs(pack_path)
    configured = ENV.fetch("BRASFOOT_LEAGUE_CONFIGS", nil)
    return all_league_configs(pack_path) if configured.blank? || configured == "all"

    configured.split(",").map(&:strip).reject(&:blank?).flat_map do |file_name|
      [
        pack_path.join("conf_ligas_nacionais", file_name),
        pack_path.join("conf_estadual", file_name)
      ]
    end.select(&:exist?)
  end

  def all_league_configs(pack_path)
    Pathname.glob(pack_path.join("conf_ligas_nacionais", "*.cfg").to_s).sort +
      Pathname.glob(pack_path.join("conf_estadual", "*.ces").to_s).sort
  end
end
