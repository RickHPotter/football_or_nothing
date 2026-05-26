# frozen_string_literal: true

class LineupSwapper
  SWAPPABLE_ATTRIBUTES = %w[lineup_slot lineup_slot_key position tactical_role starter].freeze

  def self.call(...)
    new(...).call
  end

  def initialize(lineup:, from_lineup_athlete_id:, to_lineup_athlete_id:)
    @lineup = lineup
    @from_lineup_athlete_id = from_lineup_athlete_id
    @to_lineup_athlete_id = to_lineup_athlete_id
  end

  def call
    return lineup if from_lineup_athlete_id == to_lineup_athlete_id

    from_lineup_athlete = lineup.lineup_athletes.find(from_lineup_athlete_id)
    to_lineup_athlete = lineup.lineup_athletes.find(to_lineup_athlete_id)

    LineupAthlete.transaction do
      from_attributes = from_lineup_athlete.attributes.slice(*SWAPPABLE_ATTRIBUTES)
      to_attributes = to_lineup_athlete.attributes.slice(*SWAPPABLE_ATTRIBUTES)

      from_lineup_athlete.update_columns(
        lineup_slot: temporary_slot,
        lineup_slot_key: "swap",
        updated_at: Time.current
      )
      to_lineup_athlete.update!(from_attributes)
      from_lineup_athlete.update!(to_attributes)
    end

    lineup
  end

  private

  attr_reader :lineup, :from_lineup_athlete_id, :to_lineup_athlete_id

  def temporary_slot
    @temporary_slot ||= lineup.lineup_athletes.maximum(:lineup_slot).to_i + 1
  end
end
