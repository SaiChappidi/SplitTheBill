class Trip < ApplicationRecord
  belongs_to :user

  has_many :participants, dependent: :destroy
  has_many :expenses, dependent: :destroy

  validates :name, :start_date, :end_date, presence: true
  validate :end_date_on_or_after_start_date

  def all_users
    ([ user ] + participants.includes(:user).map(&:user)).uniq
  end

  # Backward-compatible alias for older code paths.
  def members
    all_users
  end

  def total_paid_by(user)
    expenses.where(user_id: user.id).sum(:amount).to_f
  end

  def total_owed_by(user)
    total = 0.0

    expenses.includes(:expense_shares).find_each do |expense|
      shared_user_ids = expense.expense_shares.pluck(:user_id)
      shared_user_ids = all_users.map(&:id) if shared_user_ids.empty?

      if shared_user_ids.include?(user.id) && shared_user_ids.count.positive?
        total += expense.amount.to_f / shared_user_ids.count
      end
    end

    total.round(2)
  end

  def balances
    all_users.each_with_object({}) do |member, result|
      paid = total_paid_by(member)
      owed = total_owed_by(member)
      result[member] = (paid - owed).round(2)
    end
  end

  def settlement_transactions
    debtors = []
    creditors = []

    balances.each do |user, balance|
      if balance.negative?
        debtors << { user: user, amount: -balance }
      elsif balance.positive?
        creditors << { user: user, amount: balance }
      end
    end

    transactions = []
    i = 0
    j = 0

    while i < debtors.length && j < creditors.length
      amount = [ debtors[i][:amount], creditors[j][:amount] ].min.round(2)

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

  private

  def end_date_on_or_after_start_date
    return if start_date.blank? || end_date.blank?
    return if end_date >= start_date

    errors.add(:end_date, "must be on or after start date")
  end
end
