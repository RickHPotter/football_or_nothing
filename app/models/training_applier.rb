class TrainingApplier
  ATTRIBUTE_FOCUS = {
    "balanced" => %w[stamina technique teamwork],
    "fitness" => %w[stamina pace strength],
    "attacking" => %w[finishing passing composure],
    "defending" => %w[tackling marking positioning],
    "technical" => %w[technique first_touch dribbling],
    "youth_development" => %w[decisions technique work_rate]
  }.freeze

  INTENSITY_CONDITION = {
    "low" => 3,
    "normal" => 0,
    "high" => -5
  }.freeze

  INTENSITY_GROWTH = {
    "low" => 0,
    "normal" => 1,
    "high" => 2
  }.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(club:, manager:, from_date:, to_date:)
    @club = club
    @manager = manager
    @from_date = from_date
    @to_date = to_date
  end

  def call
    return [] if training_days <= 0

    plan = current_plan
    club.current_athletes.includes(:current_athlete_contract).each_with_object([]) do |athlete, results|
      results.concat(apply_to_athlete(plan, athlete))
    end
  end

  private
    attr_reader :club, :manager, :from_date, :to_date

    def current_plan
      club.training_plan || club.create_training_plan!(
        manager:,
        focus: :balanced,
        intensity: :normal,
        active_from: from_date
      )
    end

    def apply_to_athlete(plan, athlete)
      old_condition = athlete.condition
      new_condition = (old_condition + condition_delta(plan)).clamp(0, 100)
      attribute_name = attribute_for(plan, athlete)
      old_value = athlete.public_send(attribute_name)
      new_value = [ old_value + attribute_gain(plan, athlete), 20 ].min

      athlete.update!(
        condition: new_condition,
        attribute_name => new_value,
        current_ability: [ athlete.current_ability + ability_gain(plan, athlete), athlete.potential_ability ].min
      )

      return [] if old_value == new_value && old_condition == new_condition

      [
        TrainingResult.create!(
          training_plan: plan,
          club:,
          athlete:,
          occurred_on: to_date,
          attribute_name:,
          old_value:,
          new_value:,
          condition_change: new_condition - old_condition
        )
      ]
    end

    def attribute_for(plan, athlete)
      attributes = ATTRIBUTE_FOCUS.fetch(plan.focus)
      attributes[athlete.id % attributes.length]
    end

    def attribute_gain(plan, athlete)
      return 0 unless growth_weeks.positive?
      return 0 unless athlete.current_ability < athlete.potential_ability

      base = INTENSITY_GROWTH.fetch(plan.intensity)
      base += 1 if club.staff_rating(:coaching) >= 12
      base += 1 if plan.youth_development? && athlete.age && athlete.age < 23
      base += 1 if athlete.potential_ability - athlete.current_ability >= 5
      base.positive? && growth_weeks >= 1 ? 1 : 0
    end

    def ability_gain(plan, athlete)
      return 0 unless attribute_gain(plan, athlete).positive?

      plan.high? && athlete.current_ability < athlete.potential_ability ? 1 : 0
    end

    def condition_delta(plan)
      delta = INTENSITY_CONDITION.fetch(plan.intensity) * growth_weeks
      delta += growth_weeks if club.staff_rating(:fitness) >= 12
      delta
    end

    def growth_weeks
      @growth_weeks ||= [ training_days / 7, 1 ].max
    end

    def training_days
      @training_days ||= (to_date - from_date).to_i
    end
end
