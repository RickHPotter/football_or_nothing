# frozen_string_literal: true

module DataImport
  module Brasfoot
    class TeamFileParser
      ParsedTeam = Struct.new(:external_id, :name, :short_name, :stadium_name, :city, :manager_name, :players, :raw_fields,
                              keyword_init: true)
      ParsedPlayer = Struct.new(:external_id, :name, :position, :current_ability, :potential_ability, :age, :raw_fields,
                                keyword_init: true)

      POSITION_BY_CODE = {
        0 => :goalkeeper,
        1 => :full_back,
        2 => :center_back,
        3 => :central_midfielder,
        4 => :striker
      }.freeze

      def self.call(...)
        new(...).call
      end

      def initialize(path)
        @path = Pathname(path)
      end

      def call
        object = JavaSerializationReader.read(path.binread)
        fields = object.fields
        player_objects = [ *array_items(fields["l"]), *array_items(fields["m"]) ]

        ParsedTeam.new(
          external_id: path.basename(".ban").to_s,
          name: fields["e"].presence || filename_name,
          short_name: fields["d"].presence || filename_name,
          stadium_name: fields["f"].presence,
          city: nil,
          manager_name: fields["h"].presence,
          players: parse_players(player_objects),
          raw_fields: fields
        )
      end

      private

      attr_reader :path

      def parse_players(player_objects)
        player_objects.filter_map.with_index do |object, index|
          next unless object.respond_to?(:fields)

          fields = object.fields
          name = fields["a"].presence
          next if name.blank?

          ParsedPlayer.new(
            external_id: "#{path.basename('.ban')}:#{index}:#{name.parameterize}",
            name:,
            position: POSITION_BY_CODE.fetch(fields["e"], :central_midfielder),
            current_ability: rating_from(fields),
            potential_ability: potential_from(fields),
            age: fields["d"],
            raw_fields: fields
          )
        end
      end

      def array_items(object)
        return [] unless object.respond_to?(:fields)

        object.fields["items"]
      end

      def rating_from(fields)
        (fields["hash"].to_i * 2).clamp(1, 20)
      end

      def potential_from(fields)
        bonus = fields["d"].to_i <= 21 ? 2 : 0
        (rating_from(fields) + bonus).clamp(1, 20)
      end

      def filename_name
        path.basename(".ban").to_s.tr("_", " ").titleize
      end
    end
  end
end
