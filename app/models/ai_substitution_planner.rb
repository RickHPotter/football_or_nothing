# frozen_string_literal: true

class AiSubstitutionPlanner
  MINUTE_THRESHOLD = 60
  MAX_SUBSTITUTIONS = 5

  def self.call(...)
    new(...).call
  end

  def initialize(fixture:, club:, minute:)
    @fixture = fixture
    @club = club
    @minute = minute
  end

  def call
    return unless minute >= MINUTE_THRESHOLD
    return if fixture.completed? || fixture.club_substitution_count(club) >= MAX_SUBSTITUTIONS
    return if fixture.match_events.substitution.exists?(club:, minute:)
    return unless lineup

    off = player_off
    on = player_on(off)
    return unless off && on

    apply_substitution(off, on)
    create_event(on)
  end

  private

  attr_reader :fixture, :club, :minute

  def lineup
    @lineup ||= fixture.lineup_for(club)
  end

  def player_off
    lineup.lineup_athletes.starters.includes(:athlete).min_by do |lineup_athlete|
      [
        lineup_athlete.athlete.condition,
        lineup_athlete.athlete.current_ability,
        yellow_card_count(lineup_athlete.athlete),
        lineup_athlete.lineup_slot
      ]
    end
  end

  def player_on(off)
    lineup.lineup_athletes.bench
          .where(substituted_on_minute: nil, substituted_off_minute: nil)
          .includes(:athlete)
          .max_by { |lineup_athlete| bench_score(lineup_athlete, off.position) }
  end

  def bench_score(lineup_athlete, slot_position)
    athlete = lineup_athlete.athlete
    fit_bonus = athlete.position == slot_position ? 8 : 0
    fit_bonus + athlete.current_ability + athlete.condition.fdiv(10)
  end

  def apply_substitution(off, on)
    starter_attributes = slot_attributes(off)
    bench_attributes = slot_attributes(on)

    LineupAthlete.transaction do
      off.update_columns(lineup_slot: temporary_slot, lineup_slot_key: "ai_swap", updated_at: Time.current)
      on.update!(starter_attributes.merge(starter: true, substituted_on_minute: minute))
      off.update!(bench_attributes.merge(starter: false, substituted_off_minute: minute))
      increment_substitution_count!
    end
  end

  def slot_attributes(lineup_athlete)
    lineup_athlete.attributes.slice("lineup_slot", "lineup_slot_key", "position", "tactical_role")
  end

  def create_event(on)
    athlete = on.athlete
    fixture.match_events.create!(
      club:,
      athlete:,
      minute:,
      event_type: :substitution,
      description: "#{athlete.first_name} #{athlete.last_name} came on for #{club.name}."
    )
  end

  def temporary_slot
    @temporary_slot ||= lineup.lineup_athletes.maximum(:lineup_slot).to_i + 1
  end

  def yellow_card_count(athlete)
    fixture.match_events.yellow_card.where(club:, athlete:).count
  end

  def increment_substitution_count!
    match_state = fixture.match_state

    if fixture.home_club_id == club.id
      match_state.increment!(:home_substitutions)
    else
      match_state.increment!(:away_substitutions)
    end
  end
end
