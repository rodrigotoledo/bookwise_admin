# frozen_string_literal: true

User.destroy_all
librarian = User.create!(
  email_address: "ana@bookwise.com",
  password: "123456",
  user_type: :librarian
)

member1 = User.create!(
  email_address: "john@bookwise.com",
  password: "123456",
  user_type: :member
)

member2 = User.create!(
  email_address: "mary@bookwise.com",
  password: "123456",
  user_type: :member
)
