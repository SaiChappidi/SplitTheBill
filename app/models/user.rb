class User < ApplicationRecord
    has_secure_password # handle password hashing

    has_many :trips, dependent: :destroy
    has_many :participants, dependent: :destroy
    has_many :expenses, dependent: :destroy
    has_many :expense_shares, dependent: :destroy

    validates :name, presence: true
    validates :email, presence: true,
                                        uniqueness: { case_sensitive: false },
                                        format: { with: URI::MailTo::EMAIL_REGEXP }

    before_save { self.email = email.downcase }
end
