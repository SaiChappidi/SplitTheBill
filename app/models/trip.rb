class Trip < ApplicationRecord
  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :expenses, dependent: :destroy
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
end
