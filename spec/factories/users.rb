# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@bookwise.com" }
    password { "123456" }
    user_type { :member }

    trait :member do
      user_type { :member }
    end

    trait :with_password do
      password { PASSWORD_FOR_USER }
    end

    trait :librarian do
      user_type { :librarian }
    end
  end
end
