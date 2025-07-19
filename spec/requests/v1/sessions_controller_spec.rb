# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SessionsController, type: :request do
  let(:user_member) { create(:user, :member, :with_password) }
  let(:user_librarian) { create(:user, :librarian, :with_password) }

  describe "POST /sign_in" do
    context "with valid credentials" do
      it "logs in the user" do
        post api_v1_sign_in_path, params: { email_address: user_member.email_address, password: PASSWORD_FOR_USER }
        expect(response).to have_http_status(:created)
        expect(json_response).to have_key("user")
        expect(json_response).to have_key("token")
      end
    end

    context "with invalid credentials" do
      it "returns unprocessable entity" do
        post api_v1_sign_in_path, params: { email_address: user_member.email_address, password: "123" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
  describe "DELETE /logout" do
    before do
      sign_in user_member
    end

    it "logout the user" do
      delete api_v1_logout_path
      expect(response).to have_http_status(:no_content)
    end
  end

  it "returns 401 when JWT.decode raises a StandardError" do
    allow(JWT).to receive(:decode).and_raise(StandardError)

    get api_v1_books_path, headers: generate_jwt_token(user_librarian)
    expect(response).to have_http_status(:unauthorized)
  end
end
