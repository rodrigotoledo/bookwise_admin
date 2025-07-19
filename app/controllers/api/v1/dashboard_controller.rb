# frozen_string_literal: true

module Api
  module V1
    class DashboardController < Api::V1::ApplicationController
      before_action :authenticate_user!

      before_action :set_member_dashboard, only: :for_member
      before_action :set_librarian_dashboard, only: :for_librarian

      def for_member
        render json: {
          borrowings: @borrowings,
          overdue_borrowings: @overdue_borrowings
        }, status: :ok
      end

      def for_librarian
        render json: {
          total_books: @total_books,
          borrowed_books: @borrowed_books,
          books_due_today: @books_due_today,
          members_with_overdue: @members_with_overdue
        }, status: :ok
      end

      private
      def set_librarian_dashboard
        @total_books = Book.count
        @borrowed_books = Borrowing.active.count
        @books_due_today = Borrowing.active.where(due_at: Date.current.all_day)
        @members_with_overdue = User.joins(:borrowings).where(borrowings: { returned_at: nil }).where("borrowings.due_at < ?", Date.current).distinct
      end

      def set_member_dashboard
        @borrowings = current_user.borrowings.order(:due_at)
        @overdue_borrowings = current_user.overdue_borrowings
      end
    end
  end
end
