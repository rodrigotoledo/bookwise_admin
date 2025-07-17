# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  enum :user_type, member: 0, librarian: 1

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, email: true, uniqueness: true
  validates :user_type, presence: true
  validates :user_type, inclusion: { in: User.user_types.keys }, allow_blank: true
end
