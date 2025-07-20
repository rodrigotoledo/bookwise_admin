# frozen_string_literal: true

json.extract! book, :id, :title, :author, :genre, :isbn, :total_copies
json.available_copies book.available_copies

json.borrowings book.borrowings do |borrowing|
  json.extract! borrowing, :id, :borrowed_at, :due_at, :returned_at
  json.user do
    json.extract! borrowing.user, :id, :email_address
  end
end
