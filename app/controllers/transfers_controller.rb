class TransfersController < ApplicationController
  before_action :set_career
  before_action :set_club

  def index
    @finance = @club.club_finance
    @market_athletes = market_athletes
    @offers = @club.incoming_transfer_offers.includes(:athlete, :from_club).recent.limit(20)
    @transfers = @club.incoming_transfers.includes(:athlete, :from_club).order(transfer_date: :desc, created_at: :desc).limit(20)
  end

  def create
    unless transfer_window_open?
      redirect_to career_transfers_path(@career), alert: "The transfer window is closed."
      return
    end

    athlete = Athlete.find(params.expect(:athlete_id))
    TransferOffer.create!(
      athlete:,
      from_club: athlete.current_club,
      to_club: @club,
      offered_on: @career.current_date,
      expires_on: @career.current_date + 14.days,
      offered_fee: params.expect(:fee),
      offered_wage: params.expect(:wage),
      transfer_type: params[:transfer_type].presence || "permanent",
      loan_ends_on: params[:loan_ends_on].presence,
      status: :pending,
      notes: "Initial offer from #{@club.name}."
    )

    redirect_to career_transfers_path(@career), notice: "Offer submitted."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to career_transfers_path(@career), alert: error.record.errors.full_messages.to_sentence
  end

  def complete_offer
    unless transfer_window_open?
      redirect_to career_transfers_path(@career), alert: "The transfer window is closed."
      return
    end

    offer = @club.incoming_transfer_offers.find(params.expect(:id))
    TransferOfferProcessor.call(offer:, transfer_date: @career.current_date)

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

    def transfer_window_open?
      TransferWindowPolicy.open?(club: @club, date: @career.current_date)
    end
end
