# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Api::V1::ApplicationController
      def create
        data = params.permit(:email_address, :password)
        @user = User.find_by(email_address: data[:email_address])
        if @user&.authenticate(data[:password])
          @token = login(@user)
          render :create, formats: :json, status: :created
        else
          head :unprocessable_entity
        end
      end

      def destroy
        logout current_user
        head :no_content
      end
    end
  end
end
