# frozen_string_literal: true

FactoryBot.define do
  factory :borrowing do
    user
    book
  end
end
