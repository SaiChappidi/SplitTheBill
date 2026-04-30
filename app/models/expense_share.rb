class ExpenseShare < ApplicationRecord
  belongs_to :expense
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :user_id, uniqueness: { scope: :expense_id }
end
