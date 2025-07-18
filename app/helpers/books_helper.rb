# frozen_string_literal: true

module BooksHelper
  def can_borrow_book?(book)
    member? && book.available_for?(Current.user)
  end

  def available_copies?(book)
    book.available_copies.positive?
  end

  def already_borrowred?(book)
    book.borrowings.exists?(user: Current.user)
  end

  def borrowed_on(borrowing)
    l(borrowing.borrowed_at, format: :long)
  end

  def due_on(borrowing)
    l(borrowing.due_at, format: :long)
  end

  def returned_on(borrowing)
    return unless borrowing.returned_at
    l(borrowing.returned_at, format: :long)
  end
end
