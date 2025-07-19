# frozen_string_literal: true

module Api
  module V1
    module Authentication
      extend ActiveSupport::Concern

      def encode_token(payload)
        JWT.encode(payload, ENV.fetch("JWT_KEY", nil))
      end

      def decode_token
        auth_header = request.headers["Authorization"]
        return unless auth_header

        begin
          token = auth_header.split(" ").last
          JWT.decode(token, ENV.fetch("JWT_KEY", nil), true, algorithm: "HS256")
        rescue StandardError
          head :unauthorized
        end
      end

      private

      def authenticate_user!
        head :unauthorized unless user_sign_in?
      end

      def current_user
        decoded_token_info = decode_token
        return unless decoded_token_info

        begin
          user_id = decoded_token_info.first["user_id"]
          Current.user ||= User.find_by(id: user_id)
        rescue StandardError
          head :unauthorized
        end
      end

      def user_sign_in?
        current_user.present?
      end

      def require_librarian
        if !user_sign_in? || !current_user.try(:librarian?)
          head :unauthorized
        end
      end

      def login(user)
        Current.user = user
        reset_session
        encode_token({ user_id: user.id })
      end

      def logout(_user)
        Current.user = nil
        encode_token({ user_id: Faker::Internet.password })
        reset_session
      end
    end
  end
end
