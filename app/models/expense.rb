class Expense < ApplicationRecord
  belongs_to :trip
  belongs_to :user

  has_many :expense_shares, dependent: :destroy
  has_many :shared_users, through: :expense_shares, source: :user

  CATEGORIES = [ "Lodging", "Food", "Gas", "Entertainment", "Transport", "Shopping", "Other" ].freeze

  validates :description, :amount, :date, :category, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :category, inclusion: { in: CATEGORIES }
end
