class User < ApplicationRecord
    has_secure_password # handle password hashing

    # validations to ensure data integrity
    validates :name,  presence: true
    validates :email, presence: true,
                      uniqueness: { case_sensitive: false },
                      format: { with: URI::MailTo::EMAIL_REGEXP }

    # ensure emails are in consistent format
    before_save { self.email = email.downcase }
end
