# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    author { Faker::Name.name_with_middle }
    genre { Faker::Book.genre }
    isbn { "9780132350884" }
    total_copies { 3 }
  end
end
