class Trip < ApplicationRecord
  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :expenses, dependent: :destroy
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  def members
    User.where(id: Participant.where(trip_id: id).select(:user_id)).distinct
  end

  def total_paid_by(user)
    Expense.where(trip_id: id, user_id: user.id).sum(:amount).to_f
  end

  def total_owed_by(user)
    total = 0

    Expense.where(trip_id: id).find_each do |expense|
      shared_user_ids = ExpenseShare.where(expense_id: expense.id).pluck(:user_id)

      if shared_user_ids.include?(user.id) && shared_user_ids.count > 0
        total += expense.amount.to_f / shared_user_ids.count
      end
    end

    total.round(2)
  end

  def balances
    result = {}

    members.each do |member|
      paid = total_paid_by(member)
      owed = total_owed_by(member)
      result[member] = (paid - owed).round(2)
    end

    result
  end

  def settlement_transactions
    debtors = []
    creditors = []

    balances.each do |user, balance|
      if balance < 0
        debtors << { user: user, amount: -balance }
      elsif balance > 0
        creditors << { user: user, amount: balance }
      end
    end

    transactions = []
    i = 0
    j = 0

    while i < debtors.length && j < creditors.length
      amount = [debtors[i][:amount], creditors[j][:amount]].min.round(2)

      transactions << {
        from: debtors[i][:user],
        to: creditors[j][:user],
        amount: amount
      }

      debtors[i][:amount] = (debtors[i][:amount] - amount).round(2)
      creditors[j][:amount] = (creditors[j][:amount] - amount).round(2)

      i += 1 if debtors[i][:amount] <= 0
      j += 1 if creditors[j][:amount] <= 0
    end

    transactions
  end
end
