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
  ROLE_ATTACK = {
    "standard" => 0.0,
    "defend" => -0.4,
    "support" => 0.2,
    "attack" => 0.55
  }.freeze
  ROLE_DEFENSE = {
    "standard" => 0.0,
    "defend" => 0.55,
    "support" => 0.2,
    "attack" => -0.4
  }.freeze
  ROLE_CONTROL = {
    "standard" => 0.0,
    "defend" => 0.0,
    "support" => 0.35,
    "attack" => 0.1
  }.freeze
  POSITION_FALLBACKS = {
    "center_back" => %w[full_back defensive_midfielder],
    "full_back" => %w[center_back defensive_midfielder winger],
    "defensive_midfielder" => %w[center_back central_midfielder],
    "central_midfielder" => %w[defensive_midfielder attacking_midfielder],
    "attacking_midfielder" => %w[central_midfielder winger striker],
    "winger" => %w[attacking_midfielder full_back striker],
    "striker" => %w[winger attacking_midfielder]
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
      tactical_role_modifier(ROLE_ATTACK) +
      condition_modifier -
      position_fit_penalty -
      dismissal_penalty -
      injury_penalty +
      substitution_bonus
  end

  def defense_strength
    attribute_average(%i[tackling marking positioning strength decisions]) +
      club.reputation +
      mentality_defense +
      tactical_role_modifier(ROLE_DEFENSE) +
      condition_modifier -
      position_fit_penalty -
      dismissal_penalty -
      injury_penalty +
      substitution_bonus
  end

  def control_strength
    attribute_average(%i[passing first_touch teamwork work_rate decisions]) +
      mentality_attack.fdiv(2) +
      tactical_role_modifier(ROLE_CONTROL) +
      condition_modifier -
      position_fit_penalty +
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
      lineup_starters.map(&:athlete).presence ||
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

    @lineup_starters ||= lineup.lineup_athletes.starters.includes(:athlete).order(:lineup_slot).to_a
  end

  def position_fit_penalty
    return 0 if lineup_starters.empty?

    penalties = lineup_starters.sum { |lineup_athlete| position_fit_penalty_for(lineup_athlete) }
    penalties.fdiv(lineup_starters.length) * 2
  end

  def position_fit_penalty_for(lineup_athlete)
    athlete_position = lineup_athlete.athlete.position
    slot_position = lineup_athlete.position
    return 0 if athlete_position == slot_position
    return 3.0 if athlete_position == "goalkeeper" || slot_position == "goalkeeper"
    return 0.6 if POSITION_FALLBACKS.fetch(slot_position, []).include?(athlete_position)

    1.4
  end

  def tactical_role_modifier(weights)
    return 0 if lineup_starters.empty?

    lineup_starters.sum { |lineup_athlete| weights.fetch(lineup_athlete.tactical_role) }.fdiv(lineup_starters.length)
  end

  def mentality_attack
    MENTALITY_ATTACK.fetch(lineup&.mentality || "balanced")
  end

  def mentality_defense
    MENTALITY_DEFENSE.fetch(lineup&.mentality || "balanced")
  end
end
