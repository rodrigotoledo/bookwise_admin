# frozen_string_literal: true

json.user do
  json.extract! @user, :id, :email_address, :user_type, :created_at, :updated_at
end

json.token @token
