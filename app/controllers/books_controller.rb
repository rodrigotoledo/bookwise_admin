# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :require_librarian, except: %i[index borrow]
  before_action :set_book, only: %i[edit update destroy return_book borrow]

  def index
    @books = if params[:query].present?
      Book.where("title LIKE :q OR author LIKE :q OR genre LIKE :q", q: "%#{params[:query]}%")
    else
      Book.all
    end
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to books_path, notice: "Book created successfully."
    else
      flash.now[:alert] = "Ops... Please check possible errors"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @book.update(book_params)
      redirect_to books_path, notice: "Book updated successfully."
    else
      flash.now[:alert] = "Ops... Please check possible errors"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "Book deleted."
  end

  def return_book
    user = User.find(params[:user_id])
    if Borrowing.return_for(librarian: Current.user, user: user, book: @book)
      redirect_to books_path, notice: "Book returned successfully."
    else
      redirect_to books_path, alert: "Could not return the book."
    end
  rescue
    redirect_to books_path, alert: "Cant return a book without user."
  end

  def borrow
    if @book.available_for?(Current.user) && @book.borrowings.create(user: Current.user)
      redirect_to books_path, notice: "Book borrowed successfully"
    else
      redirect_to books_path, alert: "Ops... Cant borrow this Book"
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  rescue
    redirect_to books_path, alert: "Ops... Book not found"
  end

  def book_params
    params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
  end
end
