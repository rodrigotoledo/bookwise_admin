# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    if Current.user.librarian?
      librarian_dashboard
    else
      member_dashboard
    end
  end

  private

  def librarian_dashboard
    @total_books = Book.count
    @borrowed_books = Borrowing.active.count
    @books_due_today = Borrowing.active.where(due_at: Date.current.all_day)
    @members_with_overdue = User.joins(:borrowings).where(borrowings: { returned_at: nil }).where("borrowings.due_at < ?", Date.current).distinct
  end

  def member_dashboard
    @borrowings = Current.user.borrowings.order(:due_at)
    @overdue_borrowings = Current.user.overdue_borrowings
  end
end
