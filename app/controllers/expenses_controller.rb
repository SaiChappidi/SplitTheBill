class ExpensesController < ApplicationController
  before_action :require_login
  before_action :set_trip
  before_action :set_expense, only: [ :edit, :update, :destroy ]
  before_action :require_expense_editor, only: [ :edit, :update, :destroy ]

  def new
    @expense = @trip.expenses.build(date: Date.current)
    @participants = @trip.all_users
    prepare_share_form_state
  end

  def create
    @expense = @trip.expenses.build(expense_params)
    @expense.user = current_user
    @participants = @trip.all_users

    if persist_expense_with_shares
      redirect_to trip_path(@trip), notice: "Expense added."
    else
      prepare_share_form_state
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @participants = @trip.all_users
    prepare_share_form_state
  end

  def update
    @participants = @trip.all_users

    if persist_expense_with_shares
      redirect_to trip_path(@trip), notice: "Expense updated."
    else
      prepare_share_form_state
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

  def persist_expense_with_shares
    success = false

    Expense.transaction do
      success = @expense.new_record? ? @expense.save : @expense.update(expense_params)
      success &&= sync_shares
      raise ActiveRecord::Rollback unless success
    end

    success
  end

  def sync_shares
    share_user_ids = selected_share_ids
    share_amounts = normalized_share_amounts(share_user_ids)

    return false unless share_amounts

    @expense.expense_shares.delete_all

    share_user_ids.each do |user_id|
      @expense.expense_shares.create!(user_id: user_id, amount: share_amounts[user_id])
    end

    true
  end

  def selected_share_ids
    share_user_ids = params.dig(:expense, :shared_user_ids).to_a.reject(&:blank?).map(&:to_i)
    return share_user_ids if share_user_ids.any?

    @trip.all_users.map(&:id)
  end

  def normalized_share_amounts(share_user_ids)
    total_cents = amount_to_cents(@expense.amount)
    raw_amounts = params.dig(:expense, :share_amounts) || {}
    custom_cents_by_user = {}

    share_user_ids.each do |user_id|
      value = raw_amounts[user_id.to_s]
      next if value.blank?

      custom_cents_by_user[user_id] = amount_to_cents(value)
    end

    custom_total_cents = custom_cents_by_user.values.sum
    blank_user_ids = share_user_ids - custom_cents_by_user.keys

    if blank_user_ids.empty?
      unless custom_total_cents == total_cents
        @expense.errors.add(:base, "Custom amounts must add up to the expense total.")
        return nil
      end

      return custom_cents_by_user.transform_values { |cents| cents_to_amount(cents) }
    end

    remaining_cents = total_cents - custom_total_cents

    if remaining_cents.negative?
      @expense.errors.add(:base, "Custom amounts cannot exceed the expense total.")
      return nil
    end

    if remaining_cents < blank_user_ids.length
      @expense.errors.add(:base, "Each selected person must owe at least $0.01.")
      return nil
    end

    base_cents, remainder_cents = remaining_cents.divmod(blank_user_ids.length)

    blank_user_ids.each_with_index do |user_id, index|
      custom_cents_by_user[user_id] = base_cents + (index < remainder_cents ? 1 : 0)
    end

    custom_cents_by_user.transform_values { |cents| cents_to_amount(cents) }
  end

  def amount_to_cents(value)
    (BigDecimal(value.to_s) * 100).round(0).to_i
  end

  def cents_to_amount(cents)
    BigDecimal(cents.to_s) / 100
  end

  def prepare_share_form_state
    submitted_share_ids = params.dig(:expense, :shared_user_ids).to_a.reject(&:blank?).map(&:to_i)
    @selected_share_ids = submitted_share_ids.presence || @expense.expense_shares.pluck(:user_id).presence || @participants.map(&:id)

    submitted_amounts = params.dig(:expense, :share_amounts)
    @share_amount_inputs = if submitted_amounts.present?
                             submitted_amounts.respond_to?(:to_unsafe_h) ? submitted_amounts.to_unsafe_h : submitted_amounts.to_h
    else
      @expense.expense_shares.each_with_object({}) do |share, values|
        values[share.user_id.to_s] = share.amount.to_s
      end
    end
  end

  def require_expense_editor
    return if @trip.user_id == current_user.id || @expense.user_id == current_user.id

    redirect_to trip_path(@trip), alert: "You can only edit your own expenses."
  end
end
