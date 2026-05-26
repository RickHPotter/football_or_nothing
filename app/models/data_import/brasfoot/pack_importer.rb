# frozen_string_literal: true

module DataImport
  module Brasfoot
    class PackImporter
      DEFAULT_SOURCE = "brasfoot_pack"
      DEFAULT_COUNTRY_CODE = "BFP"
      DEFAULT_COUNTRY_NAME = "Brasfoot Pack"
      DEFAULT_START_DATE = Date.new(2026, 1, 1)

      COUNTRIES_BY_SUFFIX = {
        "ale" => %w[Germany GER],
        "arg" => %w[Argentina ARG],
        "aut" => %w[Austria AUT],
        "bel" => %w[Belgium BEL],
        "bra" => %w[Brazil BRA],
        "br" => %w[Brazil BRA],
        "ce" => %w[Brazil BRA],
        "cg" => %w[Brazil BRA],
        "go" => %w[Brazil BRA],
        "ma" => %w[Brazil BRA],
        "mg" => %w[Brazil BRA],
        "mt" => %w[Brazil BRA],
        "pa" => %w[Brazil BRA],
        "pb" => %w[Brazil BRA],
        "pe" => %w[Brazil BRA],
        "pr" => %w[Brazil BRA],
        "rj" => %w[Brazil BRA],
        "rn" => %w[Brazil BRA],
        "rs" => %w[Brazil BRA],
        "sc" => %w[Brazil BRA],
        "se" => %w[Brazil BRA],
        "sp" => %w[Brazil BRA],
        "bol" => %w[Bolivia BOL],
        "chi" => %w[Chile CHI],
        "chn" => %w[China CHN],
        "col" => %w[Colombia COL],
        "cro" => %w[Croatia CRO],
        "den" => %w[Denmark DEN],
        "egi" => %w[Egypt EGY],
        "eng" => %w[England ENG],
        "ing" => %w[England ENG],
        "esc" => %w[Scotland SCO],
        "esp" => %w[Spain ESP],
        "eua" => [ "United States", "USA" ],
        "fr" => %w[France FRA],
        "fra" => %w[France FRA],
        "gre" => %w[Greece GRE],
        "hol" => %w[Netherlands NED],
        "ita" => %w[Italy ITA],
        "it" => %w[Italy ITA],
        "jap" => %w[Japan JPN],
        "mex" => %w[Mexico MEX],
        "nor" => %w[Norway NOR],
        "par" => %w[Paraguay PAR],
        "per" => %w[Peru PER],
        "por" => %w[Portugal POR],
        "pt" => %w[Portugal POR],
        "rus" => %w[Russia RUS],
        "srb" => %w[Serbia SRB],
        "sue" => %w[Sweden SWE],
        "sui" => %w[Switzerland SUI],
        "tur" => %w[Turkey TUR],
        "uru" => %w[Uruguay URU],
        "ven" => %w[Venezuela VEN]
      }.freeze

      BRAZIL_STATE_SUFFIXES = %w[
        ac al am ap ba ce df es go ma mg ms mt pa pb pe pi pr rj rn ro rr rs sc se sp to
      ].freeze
      BRAZIL_COUNTRY_ID = 29

      ATTRIBUTE_BUCKETS = {
        goalkeeper: %i[positioning jumping decisions composure],
        center_back: %i[tackling marking heading strength positioning],
        full_back: %i[pace acceleration tackling crossing stamina],
        defensive_midfielder: %i[tackling marking passing teamwork strength],
        central_midfielder: %i[passing technique first_touch decisions teamwork],
        attacking_midfielder: %i[passing technique dribbling first_touch composure],
        winger: %i[pace acceleration dribbling crossing technique],
        striker: %i[finishing heading pace composure strength]
      }.freeze

      def self.call(...)
        new(...).call
      end

      def initialize(path:, source: DEFAULT_SOURCE, country_name: DEFAULT_COUNTRY_NAME, country_code: DEFAULT_COUNTRY_CODE,
                     limit: nil)
        @path = Pathname(path)
        @source = source
        @country_name = country_name
        @country_code = country_code
        @limit = limit&.to_i
      end

      def call
        DataImportRun.transaction do
          import_run
          files.each { |file| import_file(file) }
          import_run.complete!(records_processed: imported_records_count)
          import_run.update!(notes: "Skipped files: #{skipped_files.join(', ')}") if skipped_files.any?
        end
      rescue StandardError => e
        import_run.fail!(notes: e.message) if import_run&.persisted? && import_run.running?
        raise
      end

      private

      attr_reader :path, :source, :country_name, :country_code, :limit

      def import_run
        @import_run ||= DataImportRun.create!(source:, started_at: Time.current)
      end

      def import_country(resolved_name, resolved_code)
        Country.find_or_initialize_by(code: resolved_code).tap do |country|
          country.name = resolved_name
          country.external_source ||= source
          country.external_id ||= resolved_code
          country.reputation = 5
          country.status = :active
          country.save!
        end
      end

      def import_file(file)
        unless java_serialization_file?(file)
          skipped_files << "#{file.basename}: unsupported serialization header"
          return
        end

        import_team(TeamFileParser.call(file))
      rescue ArgumentError => e
        skipped_files << "#{file.basename}: #{e.message}"
      end

      def import_team(team)
        resolved_country = country_for(team)
        club = import_club(team, resolved_country)
        import_stadium(team, club, resolved_country)
        team.players.each { |player| import_player(player, club, resolved_country) }
      end

      def import_club(team, resolved_country)
        (Club.find_by(external_source: source, external_id: team.external_id) || resolved_country.clubs.find_or_initialize_by(name: team.name)).tap do |club|
          club.country = resolved_country
          club.short_name = team.short_name.to_s.first(12).presence || team.name.first(12)
          club.external_source ||= source
          club.external_id ||= team.external_id
          club.reputation = reputation_from(team.players)
          club.academy_quality = 8
          club.status = :active
          club.save!
          club.create_club_finance! unless club.club_finance
        end
      end

      def import_stadium(team, club, resolved_country)
        name = team.stadium_name.presence || "#{club.name} Ground"
        relocate_stadiums_to_country(club, resolved_country)
        existing_stadium = resolved_country.stadiums.find_by(name:)
        return existing_stadium if existing_stadium&.club == club

        club.stadiums.find_or_create_by!(name: stadium_name_for(name, club, resolved_country)) do |stadium|
          stadium.country = resolved_country
          stadium.city = team.city.presence || resolved_country.name
          stadium.capacity = capacity_for(club)
          stadium.pitch_quality = 10
          stadium.ownership = :club_owned
        end
      end

      def relocate_stadiums_to_country(club, resolved_country)
        club.stadiums.where.not(country: resolved_country).find_each do |stadium|
          stadium.update!(
            country: resolved_country,
            name: stadium_name_for(stadium.name, club, resolved_country, excluding: stadium)
          )
        end
      end

      def import_player(player, club, resolved_country)
        athlete = Athlete.find_or_initialize_by(external_source: source, external_id: player.external_id)
        first_name, last_name = split_name(player.name)
        athlete.country = resolved_country
        athlete.first_name = first_name
        athlete.last_name = last_name
        athlete.position = player.position
        athlete.birthdate = birthdate_for(player.age)
        athlete.current_ability = player.current_ability
        athlete.potential_ability = player.potential_ability
        athlete.reputation = [ player.current_ability, 20 ].min
        athlete.preferred_foot = :right
        athlete.morale = 50
        athlete.condition = 100
        assign_attributes(athlete, player)
        athlete.save!
        ensure_contract(athlete, club, player)
      end

      def ensure_contract(athlete, club, player)
        contract = AthleteContract.find_or_initialize_by(
          external_source: source,
          external_id: "contract:#{player.external_id}"
        )
        contract.athlete = athlete
        contract.club = club
        contract.start_date = DEFAULT_START_DATE
        contract.end_date = DEFAULT_START_DATE.next_year(3)
        contract.current = true
        contract.wage = wage_for(player.current_ability)
        contract.save!
      end

      def assign_attributes(athlete, player)
        base = player.current_ability.clamp(1, 20)
        Athlete::ATTRIBUTES.each { |attribute| athlete.public_send("#{attribute}=", [ base - 2, 1 ].max) }
        ATTRIBUTE_BUCKETS.fetch(player.position).each { |attribute| athlete.public_send("#{attribute}=", base) }
      end

      def files
        @files ||= begin
          return [ path ] if path.file?

          selected = Pathname.glob(path.join("*.ban").to_s).sort
          limit ? selected.first(limit) : selected
        end
      end

      def java_serialization_file?(file)
        file.binread(4) == "\xAC\xED\x00\x05".b
      end

      def imported_records_count
        Club.where(external_source: source).count + Athlete.where(external_source: source).count
      end

      def reputation_from(players)
        average = players.map(&:current_ability).then { |ratings| ratings.sum.fdiv([ ratings.size, 1 ].max) }
        average.round.clamp(1, 20)
      end

      def capacity_for(club)
        (club.reputation * 2_500).clamp(5_000, 80_000)
      end

      def wage_for(rating)
        rating * 1_000
      end

      def split_name(name)
        parts = name.squish.split
        return [ parts.first, parts.first ] if parts.one?

        [ parts[0...-1].join(" "), parts.last ]
      end

      def birthdate_for(age)
        return unless age.to_i.positive?

        DEFAULT_START_DATE.prev_year(age.to_i).change(month: 7, day: 1)
      end

      def stadium_name_for(name, club, resolved_country, excluding: nil)
        stadiums = resolved_country.stadiums
        stadiums = stadiums.where.not(id: excluding.id) if excluding
        return name unless stadiums.exists?(name:)

        candidate = "#{name} (#{club.short_name})"
        suffix = 2
        while stadiums.exists?(name: candidate)
          candidate = "#{name} (#{club.short_name} #{suffix})"
          suffix += 1
        end
        candidate
      end

      def country_for(team)
        resolved_name, resolved_code = country_identity_for(team)
        import_country(resolved_name, resolved_code)
      end

      def country_identity_for(team)
        return COUNTRIES_BY_SUFFIX.fetch("bra") if team.raw_fields["a"] == BRAZIL_COUNTRY_ID

        COUNTRIES_BY_SUFFIX.fetch(country_suffix_for(team.external_id), [ country_name, country_code ])
      end

      def country_suffix_for(external_id)
        normalized_id = external_id.to_s.downcase
        explicit_suffix = normalized_id.split("_").last
        return explicit_suffix if COUNTRIES_BY_SUFFIX.key?(explicit_suffix)

        nil
      end

      def brazil_state_suffix_for(external_id)
        normalized_id = external_id.to_s.downcase
        explicit_suffix = normalized_id.split("_").last
        return explicit_suffix if BRAZIL_STATE_SUFFIXES.include?(explicit_suffix)

        BRAZIL_STATE_SUFFIXES.find { |suffix| normalized_id.end_with?(suffix) }
      end

      def skipped_files
        @skipped_files ||= []
      end
    end
  end
end
