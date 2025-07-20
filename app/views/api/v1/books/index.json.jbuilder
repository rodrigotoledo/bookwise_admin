# frozen_string_literal: true

json.books @books do |book|
  json.partial! "api/v1/books/book", book: book
end
