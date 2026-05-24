# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "status badge supports tone classes" do
    html = status_badge("Won", tone: :good)

    assert_includes html, "badge"
    assert_includes html, "badge-good"
    assert_includes html, "Won"
  end
end
