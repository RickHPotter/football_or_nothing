# frozen_string_literal: true

class MatchStrengthCalculator
  MENTALITY_ATTACK = {
    "defensive" => -1.0,
    "balanced" => 0.0,
    "attacking" => 1.25
  }.freeze

  MENTALITY_DEFENSE = {
    "defensive" => 1.25,
    "balanced" => 0.0,
    "attacking" => -1.0
  }.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(fixture:, club:)
    @fixture = fixture
    @club = club
  end

  def call
    {
      attack: attack_strength,
      defense: defense_strength,
      control: control_strength,
      discipline: discipline_strength
    }
  end

  private

  attr_reader :fixture, :club

  def attack_strength
    attribute_average(%i[finishing passing dribbling technique composure]) +
      club.reputation +
      mentality_attack +
      condition_modifier -
      dismissal_penalty -
      injury_penalty +
      substitution_bonus
  end

  def defense_strength
    attribute_average(%i[tackling marking positioning strength decisions]) +
      club.reputation +
      mentality_defense +
      condition_modifier -
      dismissal_penalty -
      injury_penalty +
      substitution_bonus
  end

  def control_strength
    attribute_average(%i[passing first_touch teamwork work_rate decisions]) +
      mentality_attack.fdiv(2) +
      substitution_bonus
  end

  def discipline_strength
    attribute_average(%i[decisions composure teamwork])
  end

  def attribute_average(attributes)
    players = athletes_in_match
    return club.current_athletes.average(:current_ability).to_f if players.empty?

    totals = players.sum do |athlete|
      attributes.sum { |attribute| athlete.public_send(attribute) }.fdiv(attributes.length)
    end
    totals.fdiv(players.length)
  end

  def athletes_in_match
    @athletes_in_match ||= begin
      fixture.ensure_match_setup!
      lineup_starters.presence ||
        club.current_athletes.order(position: :asc, current_ability: :desc, id: :asc).limit(11).to_a
    end
  end

  def lineup
    @lineup ||= fixture.lineup_for(club)
  end

  def condition_modifier
    average_condition = athletes_in_match.sum(&:condition).fdiv([ athletes_in_match.length, 1 ].max)
    (average_condition - 70).fdiv(20)
  end

  def dismissal_penalty
    fixture.match_events.red_card.where(club:).count * 2.0
  end

  def injury_penalty
    fixture.match_events.injury.where(club:).count * 1.25
  end

  def substitution_bonus
    return 0 unless lineup

    lineup.lineup_athletes.where.not(substituted_on_minute: nil).count * 0.35
  end

  def lineup_starters
    return [] unless lineup

    lineup.lineup_athletes.starters.includes(:athlete).order(:lineup_slot).map(&:athlete)
  end

  def mentality_attack
    MENTALITY_ATTACK.fetch(lineup&.mentality || "balanced")
  end

  def mentality_defense
    MENTALITY_DEFENSE.fetch(lineup&.mentality || "balanced")
  end
end
