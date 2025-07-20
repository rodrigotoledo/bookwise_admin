# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < Api::V1::ApplicationController
      include RegistrationsConcern
      def create
        if @user.save
          @token = login(@user)
          render :create, formats: :json, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end
