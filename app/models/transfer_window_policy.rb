class TransferWindowPolicy
  PRESEASON_DAYS = 60
  POSTSEASON_DAYS = 30

  def self.open?(...)
    new(...).open?
  end

  def initialize(club:, date:)
    @club = club
    @date = date
  end

  def open?
    relevant_editions.any? { |edition| open_for_edition?(edition) } || relevant_editions.empty?
  end

  private
    attr_reader :club, :date

    def relevant_editions
      @relevant_editions ||= club
        .tournament_editions
        .where(season_year: [ date.year - 1, date.year, date.year + 1 ])
        .to_a
    end

    def open_for_edition?(edition)
      preseason_window = (edition.starts_on - PRESEASON_DAYS.days)...edition.starts_on
      postseason_window = edition.ends_on..(edition.ends_on + POSTSEASON_DAYS.days)

      preseason_window.cover?(date) || postseason_window.cover?(date)
    end
end
