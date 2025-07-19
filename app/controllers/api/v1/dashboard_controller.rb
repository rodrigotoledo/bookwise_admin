# frozen_string_literal: true

module Api
  module V1
    class DashboardController < Api::V1::ApplicationController
      before_action :authenticate_user!

      before_action :set_member_dashboard, only: :for_member
      before_action :set_librarian_dashboard, only: :for_librarian

      def for_member
        render json: {
          borrowings: @borrowings
        }, status: :ok
      end

      def for_librarian
        render json: {
          total_books: @total_books,
          borrowed_books: @borrowed_books,
          books_due_today: @books_due_today,
          members_with_overdue: @members_with_overdue.map do |user|
            {
              id: user.id,
              email_address: user.email_address,
              book_titles: user.book_titles
            }
          end
        }, status: :ok
      end

      private
      def set_librarian_dashboard
        @total_books = Book.count
        @borrowed_books = Borrowing.active.count
        @books_due_today = Borrowing.active.where(due_at: Date.current.all_day)

        # Modified query to only include truly overdue books (not due today)
        @members_with_overdue = User.joins(:borrowings)
                             .where(borrowings: { returned_at: nil })
                             .where("borrowings.due_at < ?", Date.current.beginning_of_day)
                             .select("users.*, GROUP_CONCAT(books.title, ', ') as book_titles")
                             .joins(borrowings: :book)
                             .group("users.id")
                             .distinct
      end

      def set_member_dashboard
        @borrowings = current_user.borrowings
                          .order(:due_at)
                          .includes(:book)
                          .as_json(include: { book: { only: [ :title ] } })
      end
    end
  end
end
