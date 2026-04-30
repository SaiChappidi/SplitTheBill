class TripsController < ApplicationController
  before_action :require_login
  before_action :set_trip, only: [ :show, :edit, :update, :destroy ]
  before_action :require_owner, only: [ :edit, :update, :destroy ]

  def index
    @trips = accessible_trips.order(start_date: :desc, created_at: :desc)
  end

  def show
    @expenses = @trip.expenses.includes(:user, expense_shares: :user).order(date: :desc, created_at: :desc)
    @participant_users = @trip.all_users

    @spent_by_user = Hash.new(0.0)
    @owed_by_user = Hash.new(0.0)

    @expenses.each do |expense|
      payer = expense.user
      amount = expense.amount.to_f
      shares = expense.expense_shares

      @spent_by_user[payer.id] += amount

      if shares.any? && shares.all? { |share| share.amount.present? }
        shares.each { |share| @owed_by_user[share.user_id] += share.amount.to_f }
      else
        share_users = expense.shared_users.any? ? expense.shared_users : @participant_users
        per_user_share = amount / share_users.size
        share_users.each { |share_user| @owed_by_user[share_user.id] += per_user_share }
      end
    end

    @net_balances = @participant_users.each_with_object({}) do |participant, balances|
      balances[participant.id] = @spent_by_user[participant.id] - @owed_by_user[participant.id]
    end

    @settlement_transactions = calculate_settlements(@participant_users, @net_balances)
  end

  def new
    @trip = current_user.trips.build
    @available_users = User.order(:name)
  end

  def create
    @trip = current_user.trips.build(trip_params)
    @available_users = User.order(:name)

    if @trip.save
      sync_participants
      redirect_to trip_path(@trip), notice: "Trip created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_users = User.order(:name)
  end

  def update
    @available_users = User.order(:name)

    if @trip.update(trip_params)
      sync_participants
      redirect_to trip_path(@trip), notice: "Trip updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_path, notice: "Trip deleted."
  end

  private

  def set_trip
    @trip = accessible_trips.find(params[:id])
  end

  def trip_params
    params.require(:trip).permit(:name, :start_date, :end_date)
  end

  def sync_participants
    selected_ids = params[:trip][:participant_user_ids].to_a.reject(&:blank?).map(&:to_i)
    selected_ids << current_user.id
    selected_ids.uniq!

    existing_ids = @trip.participants.pluck(:user_id)
    ids_to_add = selected_ids - existing_ids
    ids_to_remove = existing_ids - selected_ids

    ids_to_add.each { |user_id| @trip.participants.create(user_id: user_id) }
    @trip.participants.where(user_id: ids_to_remove).delete_all
  end

  def accessible_trips
    participant_trip_ids = Participant.where(user_id: current_user.id).select(:trip_id)
    Trip.where(user_id: current_user.id).or(Trip.where(id: participant_trip_ids)).distinct
  end

  def require_owner
    return if @trip.user_id == current_user.id

    redirect_to trip_path(@trip), alert: "Only the trip owner can modify trip details."
  end

  def calculate_settlements(users, balances)
    creditors = []
    debtors = []

    users.each do |user|
      balance = balances[user.id].round(2)
      creditors << { user: user, amount: balance } if balance.positive?
      debtors << { user: user, amount: -balance } if balance.negative?
    end

    transactions = []
    creditor_index = 0
    debtor_index = 0

    while creditor_index < creditors.size && debtor_index < debtors.size
      creditor = creditors[creditor_index]
      debtor = debtors[debtor_index]

      payment = [ creditor[:amount], debtor[:amount] ].min.round(2)
      transactions << {
        from: debtor[:user],
        to: creditor[:user],
        amount: payment
      }

      creditor[:amount] = (creditor[:amount] - payment).round(2)
      debtor[:amount] = (debtor[:amount] - payment).round(2)

      creditor_index += 1 if creditor[:amount] <= 0.01
      debtor_index += 1 if debtor[:amount] <= 0.01
    end

    transactions
  end
end
