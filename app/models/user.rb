class User < ApplicationRecord
  has_secure_password

  # Validation for email uniqueness
  validates :email, presence: true, uniqueness: true
end
