# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe "GET #new" do
    context "when not authenticated" do
      it "responds with success" do
        get :new
        expect(response).to have_http_status(:ok).or have_http_status(:success)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user, :member) }

      before do
        sign_in user
      end


      it "redirects to root with notice" do
        get :new
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq("You are already signed in.")
      end
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_params) do
        { user: attributes_for(:user, :member) }
      end

      it "creates a new user and redirects" do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(assigns(:after_authentication_url) || root_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          user: {
            email_address: "",
            password: "123",
            user_type: "member"
          }
        }
      end

      it "does not create user and redirects back to new" do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to redirect_to(new_registration_url)
        expect(flash[:alert]).to be_present
      end

      it "raises ParameterMissing when user param is absent" do
        expect {
          post :create
        }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end
