# frozen_string_literal: true

module BooksConcern
  extend ActiveSupport::Concern

  included do
    before_action :filter_books, only: %i[index]
    before_action :set_book_with_params, only: %i[create]
  end

  def filter_books
    @books = if params[:query].present?
      Book.where("title LIKE :q OR author LIKE :q OR genre LIKE :q", q: "%#{params[:query]}%")
    else
      Book.all
    end
  end

  def set_book_with_params
    @book = Book.new(book_params)
  end

  private

  def book_params
    if params[:book].present?
      params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
    else
      {}
    end
  end
end
