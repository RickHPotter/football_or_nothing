# frozen_string_literal: true

require "test_helper"

module DataImport
  module Brasfoot
    class ClubAssetImporterTest < ActiveSupport::TestCase
      test "attaches club images from brasfoot asset directories" do
        club = clubs(:one)
        club.update!(external_source: "brasfoot_pack", external_id: "alpha")
        teams_path = Rails.root.join("tmp", "brasfoot_asset_importer_test")
        %w[escudos escudosMini camisas camisas2 camisas3].each do |directory|
          FileUtils.mkdir_p(teams_path.join(directory))
          File.binwrite(teams_path.join(directory, "alpha.png"), png_bytes)
        end

        ClubAssetImporter.call(teams_path:)

        assert club.reload.crest.attached?
        assert club.mini_crest.attached?
        assert club.home_shirt.attached?
        assert club.away_shirt.attached?
        assert club.third_shirt.attached?
      ensure
        FileUtils.rm_rf(teams_path) if teams_path
      end

      test "reattaches matching asset when stored file is missing" do
        club = clubs(:one)
        club.update!(external_source: "brasfoot_pack", external_id: "alpha")
        teams_path = Rails.root.join("tmp", "brasfoot_asset_importer_missing_file_test")
        FileUtils.mkdir_p(teams_path.join("escudos"))
        File.binwrite(teams_path.join("escudos", "alpha.png"), png_bytes)

        ClubAssetImporter.call(teams_path:)
        missing_blob = club.reload.crest.blob
        missing_blob.service.delete(missing_blob.key)

        ClubAssetImporter.call(teams_path:)

        assert club.reload.crest.attached?
        assert_not_equal missing_blob.id, club.crest.blob.id
        assert_nothing_raised { club.crest.blob.open { |file| assert file.size.positive? } }
      ensure
        FileUtils.rm_rf(teams_path) if teams_path
      end

      private

      def png_bytes
        Base64.decode64(
          "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII="
        )
      end
    end
  end
end
