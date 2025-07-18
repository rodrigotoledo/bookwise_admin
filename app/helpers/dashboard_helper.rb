# frozen_string_literal: true

module DashboardHelper
  def overdue_borrowing_list(member)
    member.overdue_borrowings.includes(:book).pluck(:title).join(", ")
  end
end
