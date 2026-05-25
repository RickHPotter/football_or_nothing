# frozen_string_literal: true

module DataImport
  module Brasfoot
    class ClubAssetImporter
      DEFAULT_SOURCE = "brasfoot_assets"
      ASSET_DIRECTORIES = {
        crest: "escudos",
        mini_crest: "escudosMini",
        home_shirt: "camisas",
        away_shirt: "camisas2",
        third_shirt: "camisas3"
      }.freeze

      def self.call(...)
        new(...).call
      end

      def initialize(teams_path:, club_source: PackImporter::DEFAULT_SOURCE, source: DEFAULT_SOURCE)
        @teams_path = Pathname(teams_path)
        @club_source = club_source
        @source = source
        @imported_count = 0
      end

      def call
        DataImportRun.transaction do
          import_run
          ASSET_DIRECTORIES.each do |attachment_name, directory_name|
            import_directory(attachment_name, teams_path.join(directory_name))
          end
          import_run.complete!(records_processed: imported_count)
        end
      rescue StandardError => error
        import_run.fail!(notes: error.message) if import_run&.persisted? && import_run.running?
        raise
      end

      private

      attr_reader :teams_path, :club_source, :source

      def import_run
        @import_run ||= DataImportRun.create!(source:, started_at: Time.current)
      end

      def import_directory(attachment_name, directory)
        return unless directory.directory?

        Pathname.glob(directory.join("*.png").to_s).sort.each do |path|
          club = club_for(path)
          next unless club

          attach_asset(club, attachment_name, path)
        end
      end

      def attach_asset(club, attachment_name, path)
        attachment = club.public_send(attachment_name)
        return if attachment.attached? && attachment.filename.to_s == path.basename.to_s && asset_available?(attachment)

        attachment.detach if attachment.attached?

        attachment.attach(
          io: File.open(path, "rb"),
          filename: path.basename.to_s,
          content_type: "image/png"
        )
        @imported_count += 1
      end

      def asset_available?(attachment)
        attachment.blob.open { |_| true }
      rescue ActiveStorage::FileNotFoundError
        false
      end

      def club_for(path)
        external_id = path.basename(".png").to_s
        Club.find_by(external_source: club_source, external_id:) ||
          Club.find_by(external_source: club_source, external_id: normalized_asset_id(external_id))
      end

      def normalized_asset_id(external_id)
        external_id.delete_prefix("ap_")
      end

      def imported_count
        @imported_count ||= 0
      end
    end
  end
end
