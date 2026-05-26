# frozen_string_literal: true

class LineupTemplate
  Slot = Struct.new(:name, :position, :preferred_positions, :fallback_positions, keyword_init: true)

  TEMPLATES = {
    "4-4-2" => [
      [ :gk, :goalkeeper, %i[goalkeeper], [] ],
      [ :rb, :full_back, %i[full_back], %i[center_back defensive_midfielder] ],
      [ :rcb, :center_back, %i[center_back], %i[full_back defensive_midfielder] ],
      [ :lcb, :center_back, %i[center_back], %i[full_back defensive_midfielder] ],
      [ :lb, :full_back, %i[full_back], %i[center_back defensive_midfielder] ],
      [ :rm, :winger, %i[winger attacking_midfielder], %i[central_midfielder full_back] ],
      [ :rcm, :central_midfielder, %i[central_midfielder defensive_midfielder], %i[attacking_midfielder] ],
      [ :lcm, :central_midfielder, %i[central_midfielder defensive_midfielder], %i[attacking_midfielder] ],
      [ :lm, :winger, %i[winger attacking_midfielder], %i[central_midfielder full_back] ],
      [ :rst, :striker, %i[striker], %i[winger attacking_midfielder] ],
      [ :lst, :striker, %i[striker], %i[winger attacking_midfielder] ]
    ],
    "4-3-3" => [
      [ :gk, :goalkeeper, %i[goalkeeper], [] ],
      [ :rb, :full_back, %i[full_back], %i[center_back defensive_midfielder] ],
      [ :rcb, :center_back, %i[center_back], %i[full_back defensive_midfielder] ],
      [ :lcb, :center_back, %i[center_back], %i[full_back defensive_midfielder] ],
      [ :lb, :full_back, %i[full_back], %i[center_back defensive_midfielder] ],
      [ :dm, :defensive_midfielder, %i[defensive_midfielder central_midfielder], %i[center_back] ],
      [ :rcm, :central_midfielder, %i[central_midfielder], %i[defensive_midfielder attacking_midfielder] ],
      [ :lcm, :central_midfielder, %i[central_midfielder], %i[defensive_midfielder attacking_midfielder] ],
      [ :rw, :winger, %i[winger], %i[attacking_midfielder striker] ],
      [ :st, :striker, %i[striker], %i[winger attacking_midfielder] ],
      [ :lw, :winger, %i[winger], %i[attacking_midfielder striker] ]
    ],
    "4-2-3-1" => [
      [ :gk, :goalkeeper, %i[goalkeeper], [] ],
      [ :rb, :full_back, %i[full_back], %i[center_back defensive_midfielder] ],
      [ :rcb, :center_back, %i[center_back], %i[full_back defensive_midfielder] ],
      [ :lcb, :center_back, %i[center_back], %i[full_back defensive_midfielder] ],
      [ :lb, :full_back, %i[full_back], %i[center_back defensive_midfielder] ],
      [ :rdm, :defensive_midfielder, %i[defensive_midfielder central_midfielder], %i[center_back] ],
      [ :ldm, :defensive_midfielder, %i[defensive_midfielder central_midfielder], %i[center_back] ],
      [ :rw, :winger, %i[winger attacking_midfielder], %i[central_midfielder striker] ],
      [ :am, :attacking_midfielder, %i[attacking_midfielder central_midfielder], %i[winger striker] ],
      [ :lw, :winger, %i[winger attacking_midfielder], %i[central_midfielder striker] ],
      [ :st, :striker, %i[striker], %i[winger attacking_midfielder] ]
    ]
  }.freeze

  def self.for(formation)
    slots = TEMPLATES.fetch(formation, TEMPLATES.fetch("4-4-2"))
    slots.map do |name, position, preferred_positions, fallback_positions|
      Slot.new(name:, position:, preferred_positions:, fallback_positions:)
    end
  end
end
