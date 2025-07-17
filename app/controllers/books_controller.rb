# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :require_librarian, except: [ :index ]
  before_action :set_book, only: %i[edit update destroy]

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
