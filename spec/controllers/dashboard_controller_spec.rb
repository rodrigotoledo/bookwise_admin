# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user_librarian) { create(:user, :librarian) }
  let(:user_member) { create(:user, :member) }
  let(:user_member_overdue) { create(:user, :member) }

  context "when user is a librarian" do
    before do
      sign_in user_librarian
      book = create(:book)
      create(:borrowing, book: book)
      overdue_borrowing = create(:borrowing, book: book, user: user_member)
      overdue_borrowing.update_attribute(:due_at, Date.current)
      overdue_borrowing_ago = create(:borrowing, book: book, user: user_member_overdue)
      overdue_borrowing_ago.update_attribute(:due_at, Date.current - 1.day)
    end

    it "assigns all relevant variables" do
      get :index

      expect(assigns(:total_books)).to eq(Book.count)
      expect(assigns(:borrowed_books)).to eq(Borrowing.active.count)
      overdue_borrowing = Borrowing.active.where(due_at: Date.current.all_day)
      overdue_borrowing_ago = Borrowing.active.where("due_at < ?", Date.current)

      expect(assigns(:books_due_today).pluck(:id)).to include(overdue_borrowing.pluck(:id).first)
      expect(assigns(:members_with_overdue).pluck(:id)).to include(*overdue_borrowing_ago.pluck(:user_id))
    end
  end

  context "when user is a member" do
    before do
      sign_in user_member
    end

    it "assigns member's borrowings and overdue" do
      borrowing = create(:borrowing, user: user_member)
      overdue = create(:borrowing, user: user_member)
      overdue.update_attribute(:due_at, 2.days.ago)
      get :index

      expect(assigns(:borrowings)).to include(borrowing, overdue)
      expect(assigns(:overdue_borrowings)).to include(overdue)
    end
  end

  describe "GET #index" do
    context "when user is authenticated" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is not authenticated" do
      it "redirects to login page" do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
