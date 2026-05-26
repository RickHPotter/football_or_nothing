# frozen_string_literal: true

class MatchdayStandingSnapshotRecorder
  def self.call(...)
    new(...).call
  end

  def initialize(session:, stage:)
    @session = session
    @stage = stage
  end

  def call
    standings.each_with_index do |participation, index|
      snapshot = session.matchday_standing_snapshots.find_or_initialize_by(tournament_participation: participation)
      snapshot.club = participation.club
      snapshot.public_send("#{position_attribute}=", index + 1)
      snapshot.save!
    end
  end

  private

  attr_reader :session, :stage

  def standings
    session.tournament_edition.standings
  end

  def position_attribute
    case stage
    when :before then :position_before
    when :after then :position_after
    else raise ArgumentError, "Unknown snapshot stage: #{stage}"
    end
  end
end
