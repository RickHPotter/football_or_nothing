# frozen_string_literal: true

require "test_helper"

class NewsPublisherTest < ActiveSupport::TestCase
  test "creates idempotent news item" do
    assert_difference "NewsItem.count", 1 do
      2.times do
        NewsPublisher.call(
          category: :world,
          title: "Season opens",
          body: "The new season is ready.",
          occurred_on: Date.new(2026, 1, 1),
          club: clubs(:one)
        )
      end
    end

    assert NewsItem.last.world?
    assert_equal clubs(:one), NewsItem.last.club
  end
end
