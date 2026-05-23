class TransfersController < ApplicationController
  before_action :set_career
  before_action :set_club

  def index
    @finance = @club.club_finance
    @market_athletes = market_athletes
    @transfers = @club.incoming_transfers.includes(:athlete, :from_club).order(transfer_date: :desc, created_at: :desc).limit(20)
  end

  def create
    athlete = Athlete.find(params.expect(:athlete_id))
    TransferProcessor.call(
      athlete:,
      to_club: @club,
      transfer_date: @career.current_date,
      fee: params.expect(:fee),
      wage: params.expect(:wage)
    )

    redirect_to career_transfers_path(@career), notice: "Transfer completed."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to career_transfers_path(@career), alert: error.record.errors.full_messages.to_sentence
  end

  private
    def set_career
      @career = Current.user.careers.includes(manager: { current_manager_contract: :club }).find(params.expect(:career_id))
    end

    def set_club
      @club = @career.manager&.current_club
      redirect_to @career, alert: "Take a job before opening the transfer market." unless @club
    end

    def market_athletes
      Athlete
        .includes(current_athlete_contract: [ :club ])
        .where.not(id: @club.current_athletes.select(:id))
        .order(reputation: :desc, current_ability: :desc, last_name: :asc)
        .limit(30)
    end
end
