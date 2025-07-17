# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
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
