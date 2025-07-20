# frozen_string_literal: true

json.total_books @total_books
json.borrowed_books @borrowed_books
json.books_due_today @books_due_today

json.members_with_overdue @members_with_overdue do |user|
  json.id user.id
  json.email_address user.email_address
  json.book_titles user.overdue_book_titles
end
