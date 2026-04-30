class AddAmountToExpenseShares < ActiveRecord::Migration[8.1]
  def up
    add_column :expense_shares, :amount, :decimal, precision: 10, scale: 2

    ExpenseShare.reset_column_information

    ExpenseShare.includes(:expense).find_each do |share|
      next unless share.expense&.amount.present?

      share_count = share.expense.expense_shares.count
      next if share_count.zero?

      share.update_columns(amount: (share.expense.amount.to_d / share_count).round(2))
    end

    change_column_null :expense_shares, :amount, false
  end

  def down
    remove_column :expense_shares, :amount
  end
end
