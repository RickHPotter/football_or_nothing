# frozen_string_literal: true

module DataImport
  module Brasfoot
    class LeagueConfigParser
      ParsedConfig = Struct.new(:path, :kind, :name, :divisions, :raw_object, keyword_init: true)
      ParsedDivision = Struct.new(:name, :division, :team_count, :relegated_count, :format, :raw_fields, keyword_init: true)

      def self.call(...)
        new(...).call
      end

      def initialize(path)
        @path = Pathname(path)
      end

      def call
        object = JavaSerializationReader.read(path.binread)
        ParsedConfig.new(
          path: path.to_s,
          kind: kind_for(object),
          name: path.basename(path.extname).to_s,
          divisions: parse_divisions(object),
          raw_object: object
        )
      end

      private

      attr_reader :path

      def kind_for(object)
        case object.class_name
        when "est.ArrayLigaType" then :national
        when "est.ArrayLigaEType" then :state
        else :unknown
        end
      end

      def parse_divisions(object)
        items = object.fields.fetch("a").fields.fetch("items")
        items.map { |item| parse_division(item) }
      end

      def parse_division(item)
        fields = item.fields
        ParsedDivision.new(
          name: division_name(fields),
          division: fields["divisao"],
          team_count: fields["nTimes"],
          relegated_count: fields["nRebaixados"],
          format: fields["formula"],
          raw_fields: fields
        )
      end

      def division_name(fields)
        [ fields["nome"], fields["nomeDivisao"] ].compact_blank.join(" ").presence ||
          "Division #{fields['divisao']}"
      end
    end
  end
end
