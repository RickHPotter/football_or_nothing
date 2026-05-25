# frozen_string_literal: true

require "test_helper"

module DataImport
  module Brasfoot
    class JavaSerializationReaderTest < ActiveSupport::TestCase
      test "reads serialized Java strings" do
        bytes = [ "aced000574000568656c6c6f" ].pack("H*")

        assert_equal "hello", JavaSerializationReader.read(bytes)
      end

    end
  end
end
