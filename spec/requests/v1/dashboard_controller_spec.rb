# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::DashboardController, type: :request do
  let(:user_member) { create(:user, :member, :with_password) }
  let(:user_librarian) { create(:user, :librarian, :with_password) }
  let(:user_member_overdue) { create(:user, :member) }

  describe "GET /for_member" do
    before do
      create(:borrowing, user: user_member)
      overdue = create(:borrowing, user: user_member)
      overdue.update_attribute(:due_at, 2.days.ago)
    end

    it "should get data for current member" do
      get api_v1_dashboard_for_member_path, headers: generate_jwt_token(user_member)
      expect(response).to have_http_status(:ok)
      expect(json_response).to have_key("borrowings")
    end
  end

  describe "GET /for_librarian" do
    before do
      book1 = create(:book)
      book2 = create(:book)
      create(:borrowing, book: book1)
      create(:borrowing, book: book2, user: user_member)
      overdue_borrowing = create(:borrowing, book: book1, user: user_member)
      overdue_borrowing.update_attribute(:due_at, Date.current)
      overdue_borrowing_ago = create(:borrowing, book: book1, user: user_member_overdue)
      overdue_borrowing_ago.update_attribute(:due_at, Date.current - 1.day)
    end

    it "should get data for current member" do
      get api_v1_dashboard_for_librarian_path, headers: generate_jwt_token(user_librarian)
      expect(response).to have_http_status(:ok)
      expect(json_response["total_books"]).to eql(2)
      expect(json_response["borrowed_books"]).to eql(4)
      expect(json_response["books_due_today"]).to eql(1)
      expect(json_response["members_with_overdue"].size).to eql(1)
    end
  end
end
