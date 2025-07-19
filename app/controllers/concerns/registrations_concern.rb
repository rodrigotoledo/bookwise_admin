# frozen_string_literal: true

module RegistrationsConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_new_user, only: %i[create]
  end

  def set_new_user
    @user = User.new(user_params)
  end


  private

  def user_params
    params.require(:user).permit(:email_address, :password, :user_type)
  end
end
