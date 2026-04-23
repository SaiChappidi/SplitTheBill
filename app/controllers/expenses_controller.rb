class ExpensesController < ApplicationController
  before_action :require_login
  before_action :set_trip
  before_action :set_expense, only: [ :edit, :update, :destroy ]
  before_action :require_expense_editor, only: [ :edit, :update, :destroy ]
  
  def new
    @expense = @trip.expenses.build(date: Date.current)
    @participants = @trip.all_users
  end

  def create
    @expense = @trip.expenses.build(expense_params)
    @expense.user = current_user
    @participants = @trip.all_users

    if @expense.save
      sync_shares
      redirect_to trip_path(@trip), notice: "Expense added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @participants = @trip.all_users
  end

  def update
    @participants = @trip.all_users

    if @expense.update(expense_params)
      sync_shares
      redirect_to trip_path(@trip), notice: "Expense updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to trip_path(@trip), notice: "Expense deleted."
  end

  private

  def set_trip
    participant_trip_ids = Participant.where(user_id: current_user.id).select(:trip_id)
    @trip = Trip.where(user_id: current_user.id).or(Trip.where(id: participant_trip_ids)).distinct.find(params[:trip_id])
  end

  def set_expense
    @expense = @trip.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:description, :amount, :date, :category)
  end

  def sync_shares
    share_user_ids = params[:expense][:shared_user_ids].to_a.reject(&:blank?).map(&:to_i)
    share_user_ids = @trip.all_users.map(&:id) if share_user_ids.empty?

    @expense.expense_shares.where.not(user_id: share_user_ids).delete_all

    existing = @expense.expense_shares.pluck(:user_id)
    (share_user_ids - existing).each do |user_id|
      @expense.expense_shares.create!(user_id: user_id)
    end
  end

  def require_expense_editor
    return if @trip.user_id == current_user.id || @expense.user_id == current_user.id

    redirect_to trip_path(@trip), alert: "You can only edit your own expenses."
  end
end
