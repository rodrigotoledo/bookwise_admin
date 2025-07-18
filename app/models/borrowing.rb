# frozen_string_literal: true

# app/models/borrowing.rb
class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :borrowed_at, :due_at, presence: true
  validate :due_date_must_be_after_borrowed_date
  validate :book_must_be_available

  before_validation :set_borrowing_dates

  scope :active, -> { where(returned_at: nil) }

  validates :book_id, uniqueness: {
    scope: :user_id,
    conditions: -> { where(returned_at: nil) },
    message: "has already been borrowed and not yet returned"
  }

  def self.return_for(librarian:, user:, book:)
    return false unless librarian&.librarian?

    borrowing = find_by(book: book, user: user, returned_at: nil)
    return false if borrowing.nil?

    borrowing.update_attribute(:returned_at, Time.current)
  end

  def overdue?
    returned_at.nil? && due_at < Date.current
  end

  private

  def set_borrowing_dates
    self.borrowed_at ||= Time.current
    self.due_at ||= borrowed_at + 2.weeks
  end

  def due_date_must_be_after_borrowed_date
    return if borrowed_at.blank? || due_at.blank?

    if due_at <= borrowed_at
      errors.add(:due_at, "must be after the borrowing date")
    end
  end

  def book_must_be_available
    return if book.blank? || user.blank?

    unless book.available_for?(user)
      errors.add(:book, "has no available copies or is already borrowed by you")
    end
  end
end
