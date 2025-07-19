# frozen_string_literal: true

class Book < ApplicationRecord
  validates :title, :author, :genre, :isbn, :total_copies, presence: true
  validates :total_copies, numericality: { only_integer: true, greater_than: 0 }
  has_many :borrowings, dependent: :delete_all
  has_many :active_borrowings, -> { where(returned_at: nil) }, class_name: "Borrowing"
  def available_copies
    total_copies - active_borrowings.count
  end

  def available_for?(user)
    available_copies.positive? && !active_borrowings.exists?(user: user)
  end

  def borrowed_by?(user:, borrowing:)
    active_borrowings.where(user: user, id: borrowing.id).exists?
  end

  def borrowed_by(user:)
    borrowings.where(user: user)
  end
end
