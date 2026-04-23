class Trip < ApplicationRecord
  belongs_to :user

  has_many :participants, dependent: :destroy
  has_many :expenses, dependent: :destroy

  validates :name, :start_date, :end_date, presence: true
  validate :end_date_on_or_after_start_date

  def all_users
    ([ user ] + participants.includes(:user).map(&:user)).uniq
  end

  private

  def end_date_on_or_after_start_date
    return if start_date.blank? || end_date.blank?
    return if end_date >= start_date

    errors.add(:end_date, "must be on or after start date")
  end
end
