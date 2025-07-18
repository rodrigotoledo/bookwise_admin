# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user_member) { create(:user, :member) }

  describe "sign out" do
    before do
      sign_in user_member
    end

    it "calls terminate_session and redirects to login" do
      delete :destroy
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "POST #create" do
    let(:user_member) { create(:user, :member) }

    context "with valid credentials" do
      it "authenticates and redirects" do
        post :create, params: {
          email_address: user_member.email_address,
          password: "123456"
        }

        expect(response).to redirect_to(controller.send(:after_authentication_url))
      end
    end

    context "with invalid credentials" do
      it "redirects to login with alert" do
        post :create, params: {
          email_address: user_member.email_address,
          password: "wrongpassword"
        }

        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).not_to be_blank
      end
    end
  end
end
