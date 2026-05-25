# frozen_string_literal: true

require "test_helper"

module DataImport
  module Brasfoot
    class JavaSerializationReaderTest < ActiveSupport::TestCase
      test "reads serialized Java strings" do
        bytes = [ "aced000574000568656c6c6f" ].pack("H*")

        assert_equal "hello", JavaSerializationReader.read(bytes)
      end

      test "reads serialized Java primitive integer arrays" do
        bytes = [ "aced0005757200025b494dba602676eab2a5020000787000000003000000010000000200000003" ].pack("H*")

        assert_equal [ 1, 2, 3 ], JavaSerializationReader.read(bytes)
      end
    end
  end
end
