# frozen_string_literal: true

module Api
  module V1
    class BooksController < Api::V1::ApplicationController
      include BooksConcern
      before_action :authenticate_user!
      before_action :require_librarian, except: %i[index borrow]
      before_action :set_book, only: %i[update destroy return_book borrow]

      def index
        render :index, formats: :json, status: :ok
      end


      def create
        if @book.save
          render :create, formats: :json, status: :created
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @book.update(book_params)
          render :update, formats: :json, status: :ok
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @book.destroy
        head :no_content
      end

      def return_book
        user = User.find(params[:user_id])
        if Borrowing.return_for(librarian: current_user, user: user, book: @book)
          head :ok
        else
          head :unprocessable_entity
        end
      rescue
        head :not_found
      end

      def borrow
        if @book.available_for?(current_user)
          @borrowing = @book.borrowings.build(user: current_user)
          if @borrowing.save
            render :borrow, formats: :json, status: :created
          else
            render json: { errors: @borrowing.errors.full_messages }, status: :unprocessable_entity
          end
        else
          head :unprocessable_entity
        end
      end

      private

      def set_book
        @book = Book.find(params[:id])
      rescue
        head :unprocessable_entity
      end
    end
  end
end
