class SquadNeedsAnalyzer
  POSITION_MINIMUMS = {
    "goalkeeper" => 2,
    "center_back" => 3,
    "full_back" => 3,
    "defensive_midfielder" => 1,
    "central_midfielder" => 3,
    "attacking_midfielder" => 1,
    "winger" => 2,
    "striker" => 2
  }.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(club:)
    @club = club
  end

  def call
    POSITION_MINIMUMS.filter_map do |position, minimum|
      current_count = position_counts.fetch(position, 0)
      next if current_count >= minimum

      [ position, minimum - current_count ]
    end.to_h
  end

  private
    attr_reader :club

    def position_counts
      @position_counts ||= club.current_athletes.group(:position).count
    end
end
