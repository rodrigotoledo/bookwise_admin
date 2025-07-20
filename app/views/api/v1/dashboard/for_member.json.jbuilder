# frozen_string_literal: true

json.borrowings @borrowings do |borrowing|
  json.extract! borrowing, :id, :borrowed_at, :due_at, :returned_at
  json.book do
    json.title borrowing.book.title
  end
end
