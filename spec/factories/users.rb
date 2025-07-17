# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@bookwise.com" }
    password { "123456" }

    trait :member do
      user_type { :member }
    end

    trait :librarian do
      user_type { :librarian }
    end
  end
end
