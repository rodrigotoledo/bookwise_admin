# frozen_string_literal: true

# spec/helpers/dashboard_helper_spec.rb
require 'rails_helper'

RSpec.describe DashboardHelper, type: :helper do
  describe "#overdue_borrowing_list" do
    let(:user_member) { create(:user, :member) }

    it "returns a sentence with book titles" do
      book1 = create(:book, title: "Clean Code")
      book2 = create(:book, title: "Refactoring")

      borrowing1 = create(:borrowing, user: user_member, book: book1)
      borrowing1.update_columns(borrowed_at: 10.days.ago, due_at: 5.days.ago)
      borrowing2 = create(:borrowing, user: user_member, book: book2)
      borrowing2.update_columns(borrowed_at: 12.days.ago, due_at: 3.days.ago)

      result = helper.overdue_borrowing_list(user_member)
      expect(result).to eq("Clean Code, Refactoring") # ou com vírgula se mais de 2
    end

    it "returns empty string if no overdue borrowings" do
      result = helper.overdue_borrowing_list(user_member)
      expect(result).to eq("")
    end
  end
end
