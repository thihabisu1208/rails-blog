class User < ApplicationRecord
  has_many :posts, dependent: :destroy

  has_secure_password

  # Email validations
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "must be a valid email address"
    }

  # Password validations
  validates :password,
    length: { minimum: 6, message: "must be at least 6 characters" },
    if: -> { password.present? }

  # Normalize email before validation (so validation sees normalized email)
  before_validation :normalize_email

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
