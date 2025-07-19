# frozen_string_literal: true

User.destroy_all
Book.destroy_all
Borrowing.destroy_all

librarian = User.create!(
  email_address: "faker@test.com",
  password: "password",
  user_type: :librarian
)
User.create!(
  email_address: "foo@bar.com",
  password: "foo@bar.com",
  user_type: :member
)

members = 3.times.map do |i|
  User.create!(
    email_address: "member#{i + 1}@bookwise.com",
    password: "password",
    user_type: :member
  )
end

books = [
  { title: "Clean Code", author: "Robert C. Martin", genre: "Tech", isbn: "9780132350884" },
  { title: "The Pragmatic Programmer", author: "Andy Hunt", genre: "Tech", isbn: "9780201616224" },
  { title: "Sapiens", author: "Yuval Noah Harari", genre: "History", isbn: "9780062316097" },
  { title: "Atomic Habits", author: "James Clear", genre: "Self-help", isbn: "9780735211292" },
  { title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy", isbn: "9780345339683" },
  { title: "Refactoring", author: "Martin Fowler", genre: "Tech", isbn: "9780201485677" },
  { title: "Dune", author: "Frank Herbert", genre: "Sci-Fi", isbn: "9780441172719" },
  { title: "Thinking, Fast and Slow", author: "Daniel Kahneman", genre: "Psychology", isbn: "9780374533557" },
  { title: "1984", author: "George Orwell", genre: "Fiction", isbn: "9780451524935" },
  { title: "Educated", author: "Tara Westover", genre: "Memoir", isbn: "9780399590504" }
].map do |book_attrs|
  Book.create!(**book_attrs, total_copies: rand(2..3))
end

# active borrowing
Book.limit(3).order(:id).each do |book|
  borrowing = Borrowing.create!(user: User.member.first, book: book)
  borrowing.update_columns(borrowed_at: 3.days.ago, due_at: 11.days.from_now)
end

# returned
book = Book.first
borrowing = book.active_borrowings.find_by(user: User.member.first)
borrowing.update_columns(returned_at: 11.days.from_now)

# overdue bookings
Book.limit(3).order(id: :desc).each do |book|
  borrowing = Borrowing.create!(user: User.member.first, book: book)
  borrowing.update_columns(borrowed_at: 20.days.ago, due_at: 6.days.ago)
end
