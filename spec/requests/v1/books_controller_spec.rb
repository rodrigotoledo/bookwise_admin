# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::BooksController, type: :request do
  let(:user_member) { create(:user, :member, :with_password) }
  let(:user_librarian) { create(:user, :librarian, :with_password) }

  describe "as librarian" do
    describe "GET #index" do
      let!(:book1) { create(:book, title: "The Pragmatic Programmer", author: "Andy Hunt", genre: "Tech") }
      let!(:book2) { create(:book, title: "Clean Code", author: "Robert C. Martin", genre: "Tech") }
      let!(:book3) { create(:book, title: "Sapiens", author: "Yuval Noah Harari", genre: "History") }
      let!(:book4) { create(:book, title: "Sapiens 2", author: "Yuval Noah Harari", genre: "History") }

      context "without search query" do
        it "returns all books" do
          get api_v1_books_path, headers: generate_jwt_token(user_librarian)
          expect(response).to have_http_status(:ok)
          expect(json_response["books"].size).to eql(4)
        end
      end

      context "with matching search query" do
        it "returns filtered books" do
          get api_v1_books_path, params: { query: "Clean" }, headers: generate_jwt_token(user_librarian)
          expect(include_json_subset?({ "id" => book2.id }, json_response["books"])).to be true
        end

        it "returns multiple filtered books" do
          get api_v1_books_path, params: { query: "History" }, headers: generate_jwt_token(user_librarian)
          expect(include_json_subset?({ "id" => book3.id }, json_response["books"])).to be true
          expect(include_json_subset?({ "id" => book4.id }, json_response["books"])).to be true
        end
      end
    end

    describe "PATCH #update" do
      let(:book) { create(:book) }

      it "updates the book and returns 201" do
        patch api_v1_book_path(book), params: { book: { title: "New Title" } }, headers: generate_jwt_token(user_librarian)

        expect(response).to have_http_status(:ok)
        expect(json_response["title"]).to eq("New Title")
      end

      it "fails to update with invalid params and returns errors" do
        patch api_v1_book_path(book), params: { book: { title: "" } }, headers: generate_jwt_token(user_librarian)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["errors"]).to include("Title can't be blank")
      end

      it "returns 422 when book is not found" do
        patch api_v1_book_path(-1), headers: generate_jwt_token(user_librarian)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "DELETE #destroy" do
      let!(:book) { create(:book) }

      it "deletes the book and returns 204" do
        delete api_v1_book_path(book), headers: generate_jwt_token(user_librarian)

        expect(response).to have_http_status(:no_content)
        expect(Book.exists?(book.id)).to be_falsey
      end
    end
  end

  describe "PATCH #return_book" do
    let(:book) { create(:book) }
    let!(:borrowing) { create(:borrowing, book: book, user: user_member) }

    it "marks the book as returned and returns 200" do
      patch return_api_v1_book_path(book, user_id: user_member.id), headers: generate_jwt_token(user_librarian)

      expect(response).to have_http_status(:ok)
      expect(borrowing.reload.returned_at).not_to be_nil
    end

    it "fails if user not found" do
      patch return_api_v1_book_path(book, user_id: -1), headers: generate_jwt_token(user_librarian)

      expect(response).to have_http_status(:not_found)
    end

    context "" do
      before do
        allow(Borrowing).to receive(:return_for).and_return(false)
      end

      it "fails when cant return_for" do
        patch return_api_v1_book_path(book, user_id: user_member.id), headers: generate_jwt_token(user_librarian)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #borrow" do
    let(:book) { create(:book, total_copies: 1) }

    it "borrows the book successfully" do
      patch borrow_api_v1_book_path(book), headers: generate_jwt_token(user_member)

      expect(response).to have_http_status(:created)
      expect(book.borrowings.count).to eq(1)
    end

    it "fails if no copies available" do
      create(:borrowing, book: book, user: create(:user, user_type: "member"))

      patch borrow_api_v1_book_path(book), headers: generate_jwt_token(user_member)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 and error messages when save fails unexpectedly" do
      book = create(:book)

      allow_any_instance_of(Borrowing).to receive(:save).and_return(false)

      allow_any_instance_of(Borrowing).to receive(:errors).and_return(
        double(full_messages: ["Something went wrong"])
      )

      patch borrow_api_v1_book_path(book), headers: generate_jwt_token(user_member)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["errors"]).to include("Something went wrong")
    end
  end

  describe "POST #create" do
    let(:user_librarian) { create(:user, :librarian) }
    let(:book_attributes) {attributes_for(:book)}

    it 'create a book' do
      post api_v1_books_path, params: { book: book_attributes }, headers: generate_jwt_token(user_librarian)
      expect(response).to have_http_status(:created)
    end

    it "returns unauthorized for user member" do
      post api_v1_books_path, headers: generate_jwt_token(user_member)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 422 and error messages when book creation fails" do
      post api_v1_books_path, headers: generate_jwt_token(user_librarian)


      expect(response).to have_http_status(:unprocessable_entity)
      expected_errors = { "errors" => ["Title can't be blank", "Author can't be blank", "Genre can't be blank", "Isbn can't be blank", "Total copies can't be blank", "Total copies is not a number"] }
      expect(include_json_subset?(expected_errors, json_response)).to be true
    end
  end

end
