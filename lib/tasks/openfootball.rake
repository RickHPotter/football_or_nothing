# frozen_string_literal: true

require "json"
require "open-uri"

namespace :openfootball do
  Dataset = Struct.new(:key, :url, :country_name, :country_code, :competition_name, :short_name, :season_year, keyword_init: true)

  FOOTBALL_JSON_LEAGUES = [
    [ "england-premier-league", "en.1", "England", "ENG", "Premier League", "EPL" ],
    [ "england-championship", "en.2", "England", "ENG", "Championship", "EFLCH" ],
    [ "england-league-one", "en.3", "England", "ENG", "League One", "EFLL1" ],
    [ "england-league-two", "en.4", "England", "ENG", "League Two", "EFLL2" ],
    [ "germany-bundesliga", "de.1", "Germany", "GER", "Bundesliga", "BUND" ],
    [ "spain-la-liga", "es.1", "Spain", "ESP", "La Liga", "LIGA" ],
    [ "italy-serie-a", "it.1", "Italy", "ITA", "Serie A", "SERA" ],
    [ "france-ligue-1", "fr.1", "France", "FRA", "Ligue 1", "LIG1" ]
  ].freeze

  WORLD_CUP_YEARS = [ 2026, 2022, 2018, 2014 ].freeze

  EUROPEAN_JSON_DATASETS = [
    [ "champions-league", "https://openfootball.github.io/champions-league/%<season>s/cl.json", "Europe", "EUR", "UEFA Champions League", "UCL" ],
    [ "europa-league", "https://openfootball.github.io/champions-league/%<season>s/el.json", "Europe", "EUR", "UEFA Europa League", "UEL" ]
  ].freeze

  SOUTH_AMERICA_JSON_DATASETS = [
    [ "copa-america", "https://openfootball.github.io/copa-america/%<year>s/copa-america.json", "South America", "SAM", "Copa America", "COPA" ],
    [ "copa-libertadores", "https://openfootball.github.io/copa-libertadores/%<year>s/copa-libertadores.json", "South America", "SAM", "Copa Libertadores", "LIB" ]
  ].freeze

  desc "Import curated OpenFootball datasets. Env: OPENFOOTBALL_SEASONS=2023-24 OPENFOOTBALL_YEARS=2024,2022 OPENFOOTBALL_DATASETS=football_json,worldcup_json,england,champions_league,south_america OPENFOOTBALL_STRICT=true"
  task master: :environment do
    importer = MasterImporter.new(
      seasons: env_list("OPENFOOTBALL_SEASONS", [ "2023-24" ]),
      years: env_list("OPENFOOTBALL_YEARS", %w[2024 2022]).map(&:to_i),
      datasets: env_list("OPENFOOTBALL_DATASETS", %w[football_json worldcup_json england champions_league south_america]),
      strict: ActiveModel::Type::Boolean.new.cast(ENV.fetch("OPENFOOTBALL_STRICT", false))
    )
    importer.call
  end

  desc "Import one OpenFootball JSON URL. Args: url,country_name,country_code,source,competition_name,short_name,season_year"
  task :url, %i[url country_name country_code source competition_name short_name season_year] => :environment do |_task, args|
    required_arg!(args, :url)
    required_arg!(args, :country_name)
    required_arg!(args, :country_code)

    ImportOne.call(
      Dataset.new(
        key: args[:source].presence || "openfootball:url",
        url: args[:url],
        country_name: args[:country_name],
        country_code: args[:country_code],
        competition_name: args[:competition_name],
        short_name: args[:short_name],
        season_year: args[:season_year]&.to_i
      )
    )
  end

  desc "Import one local OpenFootball JSON file. Args: path,country_name,country_code,source,competition_name,short_name,season_year"
  task :file, %i[path country_name country_code source competition_name short_name season_year] => :environment do |_task, args|
    required_arg!(args, :path)
    required_arg!(args, :country_name)
    required_arg!(args, :country_code)

    ImportOne.call(
      Dataset.new(
        key: args[:source].presence || "openfootball:file",
        url: args[:path],
        country_name: args[:country_name],
        country_code: args[:country_code],
        competition_name: args[:competition_name],
        short_name: args[:short_name],
        season_year: args[:season_year]&.to_i
      ),
      local_file: true
    )
  end

  class MasterImporter
    def initialize(seasons:, years:, datasets:, strict:)
      @seasons = seasons
      @years = years
      @datasets = datasets
      @strict = strict
    end

    def call
      selected_datasets.each do |dataset|
        ImportOne.call(dataset)
      rescue OpenURI::HTTPError, SocketError, Errno::ECONNREFUSED, JSON::ParserError, KeyError, ActiveRecord::RecordInvalid => e
        raise if strict

        warn "[openfootball] skipped #{dataset.key}: #{e.class} #{e.message}"
      end
    end

    private

    attr_reader :seasons, :years, :datasets, :strict

    def selected_datasets
      entries = []
      entries.concat(football_json_entries) if datasets.include?("football_json")
      entries.concat(england_entries) if datasets.include?("england")
      entries.concat(worldcup_json_entries) if datasets.include?("worldcup_json")
      entries.concat(champions_league_entries) if datasets.include?("champions_league")
      entries.concat(south_america_entries) if datasets.include?("south_america")
      entries.uniq(&:url)
    end

    def football_json_entries
      seasons.flat_map do |season|
        FOOTBALL_JSON_LEAGUES.map do |key, code, country_name, country_code, competition_name, short_name|
          Dataset.new(
            key: "football_json:#{key}:#{season}",
            url: "https://raw.githubusercontent.com/openfootball/football.json/master/#{season}/#{code}.json",
            country_name:,
            country_code:,
            competition_name:,
            short_name:
          )
        end
      end
    end

    def england_entries
      seasons.flat_map do |season|
        FOOTBALL_JSON_LEAGUES.select { |key, *_| key.start_with?("england-") }.map do |key, code, country_name, country_code, competition_name, short_name|
          Dataset.new(
            key: "england:#{key}:#{season}",
            url: "https://raw.githubusercontent.com/openfootball/football.json/master/#{season}/#{code}.json",
            country_name:,
            country_code:,
            competition_name:,
            short_name:
          )
        end
      end
    end

    def worldcup_json_entries
      WORLD_CUP_YEARS.map do |year|
        Dataset.new(
          key: "worldcup_json:#{year}",
          url: "https://raw.githubusercontent.com/openfootball/worldcup.json/master/#{year}/worldcup.json",
          country_name: "World",
          country_code: "WRL",
          competition_name: "World Cup",
          short_name: "WC",
          season_year: year
        )
      end
    end

    def champions_league_entries
      seasons.flat_map do |season|
        EUROPEAN_JSON_DATASETS.map do |key, url_template, country_name, country_code, competition_name, short_name|
          Dataset.new(
            key: "champions_league:#{key}:#{season}",
            url: format(url_template, season:),
            country_name:,
            country_code:,
            competition_name:,
            short_name:
          )
        end
      end
    end

    def south_america_entries
      years.flat_map do |year|
        SOUTH_AMERICA_JSON_DATASETS.map do |key, url_template, country_name, country_code, competition_name, short_name|
          Dataset.new(
            key: "south_america:#{key}:#{year}",
            url: format(url_template, year:),
            country_name:,
            country_code:,
            competition_name:,
            short_name:,
            season_year: year
          )
        end
      end
    end
  end

  class ImportOne
    def self.call(...)
      new(...).call
    end

    def initialize(dataset, local_file: false)
      @dataset = dataset
      @local_file = local_file
    end

    def call
      payload = JSON.parse(read_payload)
      edition = DataImport::OpenFootballCompetitionImporter.call(
        source: dataset.key,
        payload:,
        country_name: dataset.country_name,
        country_code: dataset.country_code,
        competition_name: dataset.competition_name,
        short_name: dataset.short_name,
        season_year: dataset.season_year
      )
      puts "[openfootball] imported #{dataset.key}: #{edition.name} (#{edition.fixtures.count} fixtures)"
      edition
    end

    private

    attr_reader :dataset, :local_file

    def read_payload
      local_file ? File.read(dataset.url) : URI.open(dataset.url, read_timeout: 30).read
    end
  end

  def env_list(key, default)
    ENV.fetch(key, nil).presence&.split(",")&.map(&:strip)&.reject(&:blank?) || default
  end

  def required_arg!(args, key)
    raise ArgumentError, "missing #{key}" if args[key].blank?
  end
end
