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


Book.destroy_all

books = Book.create!([
  { title: "1984", author: "George Orwell", genre: "Fiction", isbn: "9780451524935", total_copies: 4 },
  { title: "Sapiens", author: "Yuval Noah Harari", genre: "History", isbn: "9780062316110", total_copies: 6 },
  { title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy", isbn: "9780261103344", total_copies: 3 },
  { title: "Clean Code", author: "Robert C. Martin", genre: "Technology", isbn: "9780132350884", total_copies: 5 },
  { title: "Dom Casmurro", author: "Machado de Assis", genre: "Novel", isbn: "9788594318667", total_copies: 1 }
])
