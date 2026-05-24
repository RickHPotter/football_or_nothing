class ScoutingAssignmentProcessor
  REPORT_LIMIT = 5

  def self.call(...)
    new(...).call
  end

  def initialize(club:, date:)
    @club = club
    @date = date
  end

  def call
    assignments.each_with_object([]) do |assignment, reports|
      reports.concat(generate_reports_for(assignment))
      assignment.update!(status: :completed)
    end
  end

  private
    attr_reader :club, :date

    def assignments
      club.scouting_assignments.active.where(ends_on: ..date).order(:ends_on, :id)
    end

    def generate_reports_for(assignment)
      candidates_for(assignment).map do |athlete|
        ScoutReport.find_or_initialize_by(club:, athlete:).tap do |report|
          report.scouting_assignment = assignment
          report.observed_current_ability = observed_value(athlete.current_ability, athlete.id)
          report.observed_potential_ability = observed_value(athlete.potential_ability, athlete.id + 1)
          report.confidence = confidence_for(assignment)
          report.summary = summary_for(assignment, athlete)
          report.created_on = date
          report.save!
        end
      end
    end

    def candidates_for(assignment)
      scope = Athlete
        .includes(:country, :current_athlete_contract)
        .where.not(id: club.current_athletes.select(:id))
      scope = scope.where(country: assignment.country) if assignment.country
      scope = scope.where(position: assignment.position) if assignment.position
      scope = scope.where("potential_ability >= current_ability + 3") if assignment.youth?
      scope = scope.where(reputation: ..club.reputation) if assignment.bargain?

      scope.order(current_ability: :desc, potential_ability: :desc, id: :asc).limit(REPORT_LIMIT)
    end

    def observed_value(value, seed)
      (value + ((seed % 3) - 1)).clamp(1, 20)
    end

    def confidence_for(assignment)
      base = assignment.general? ? 60 : 70
      assignment.country.present? || assignment.position.present? ? base + 10 : base
    end

    def summary_for(assignment, athlete)
      "#{assignment.focus.humanize} report for #{athlete.position.humanize.downcase} from #{athlete.country.name}."
    end
end
