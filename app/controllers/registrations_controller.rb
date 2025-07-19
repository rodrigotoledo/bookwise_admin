# frozen_string_literal: true

class RegistrationsController < ApplicationController
  include RegistrationsConcern
  allow_unauthenticated_access
  before_action :resume_session, only: :new
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    @user= User.new
    redirect_to root_url, notice: "You are already signed in." if authenticated?
  end

  def create
    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Signed up."
    else
      redirect_to new_registration_url, alert: @user.errors.full_messages.to_sentence
    end
  end
end
