# frozen_string_literal: true

class Fixture < ApplicationRecord
  enum :status, { scheduled: 0, in_progress: 1, completed: 2, postponed: 3, cancelled: 4 }

  belongs_to :tournament_edition
  belongs_to :home_club, class_name: "Club"
  belongs_to :away_club, class_name: "Club"
  belongs_to :stadium
  has_many :match_events, dependent: :destroy
  has_many :match_stats, dependent: :destroy
  has_many :lineups, dependent: :destroy
  has_one :match_state, dependent: :destroy

  validates :scheduled_on, :round, presence: true
  validates :kickoff_minute, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 1440 }
  validates :home_club_id, uniqueness: { scope: %i[tournament_edition_id away_club_id] }
  validate :clubs_must_differ

  def involves?(club)
    home_club_id == club&.id || away_club_id == club&.id
  end

  def scoreline
    return "vs" unless completed?

    "#{home_goals}-#{away_goals}"
  end

  def ensure_match_setup!
    transaction do
      create_match_state! unless match_state
      [ home_club, away_club ].each { |club| ensure_lineup_for!(club) }
    end
  end

  def lineup_for(club)
    lineups.find_by(club:)
  end

  def club_substitution_count(club)
    return 0 unless match_state

    home_club_id == club.id ? match_state.home_substitutions : match_state.away_substitutions
  end

  private

  def ensure_lineup_for!(club)
    lineup = lineups.find_or_create_by!(club:) do |record|
      record.formation = "4-4-2"
      record.mentality = :balanced
    end
    if lineup.lineup_athletes.exists?
      LineupSquadCompleter.call(lineup:, date: scheduled_on) if match_state&.not_started?
      return
    end

    LineupBuilder.call(lineup:, date: scheduled_on)
  end

  def clubs_must_differ
    errors.add(:away_club, "must differ from home club") if home_club_id == away_club_id
  end
end
