# frozen_string_literal: true

class LiveSubstitutionProcessor
  class Error < StandardError; end

  def self.call(...)
    new(...).call
  end

  def initialize(fixture:, club:, matchday_session:, off_lineup_athlete_id:, on_lineup_athlete_id:)
    @fixture = fixture
    @club = club
    @matchday_session = matchday_session
    @off_lineup_athlete_id = off_lineup_athlete_id
    @on_lineup_athlete_id = on_lineup_athlete_id
  end

  def call
    validate_context!

    LineupAthlete.transaction do
      apply_lineup_change!
      retarget_future_events!
      increment_substitution_count!
      create_timeline_event!
    end
  end

  private

  attr_reader :fixture, :club, :matchday_session, :off_lineup_athlete_id, :on_lineup_athlete_id

  def validate_context!
    raise Error, "Start the matchday clock first." unless matchday_session
    raise Error, "Pause matchday before making substitutions." unless matchday_session.paused?
    raise Error, "Substitutions are only available for your club." unless fixture.involves?(club)
    raise Error, "Match is already completed." if fixture.completed?
    raise Error, "This fixture is not part of the current matchday." unless matchday_session.includes_fixture?(fixture)
    raise Error, "All substitutions have been used." if fixture.club_substitution_count(club) >= 5
  end

  def off
    @off ||= lineup.lineup_athletes.starters.find(off_lineup_athlete_id)
  end

  def on
    @on ||= lineup.lineup_athletes.bench.where(substituted_on_minute: nil, substituted_off_minute: nil).find(on_lineup_athlete_id)
  end

  def lineup
    @lineup ||= fixture.lineup_for(club) || raise(Error, "No managed lineup available.")
  end

  def minute
    @minute ||= matchday_session.minute.clamp(0, 90)
  end

  def apply_lineup_change!
    starter_attributes = slot_attributes(off)
    bench_attributes = slot_attributes(on)

    off.update_columns(lineup_slot: temporary_slot, lineup_slot_key: "live_substitution", updated_at: Time.current)
    on.update!(starter_attributes.merge(starter: true, substituted_on_minute: minute))
    off.update!(bench_attributes.merge(starter: false, substituted_off_minute: minute))
  end

  def slot_attributes(lineup_athlete)
    lineup_athlete.attributes.slice("lineup_slot", "lineup_slot_key", "position", "tactical_role")
  end

  def temporary_slot
    @temporary_slot ||= lineup.lineup_athletes.maximum(:lineup_slot).to_i + 1
  end

  def retarget_future_events!
    matchday_session.matchday_events.pending.where(fixture:, club:, athlete: off.athlete, minute: (minute + 1)..).find_each do |event|
      event.update!(
        athlete: on.athlete,
        description: retargeted_description(event.description)
      )
    end
  end

  def retargeted_description(description)
    description.gsub("#{off.athlete.first_name} #{off.athlete.last_name}", "#{on.athlete.first_name} #{on.athlete.last_name}")
  end

  def increment_substitution_count!
    if fixture.home_club_id == club.id
      fixture.match_state.increment!(:home_substitutions)
    else
      fixture.match_state.increment!(:away_substitutions)
    end
  end

  def create_timeline_event!
    fixture.match_events.create!(
      club:,
      athlete: on.athlete,
      minute: [ minute, 1 ].max,
      event_type: :substitution,
      description: "#{on.athlete.first_name} #{on.athlete.last_name} replaced #{off.athlete.first_name} #{off.athlete.last_name} for #{club.name}."
    )
  end
end
