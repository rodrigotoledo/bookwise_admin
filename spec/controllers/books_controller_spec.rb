# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let(:user_librarian) { create(:user, :librarian) }
  describe "as librarian" do
    before do
      sign_in user_librarian
    end

    describe "GET #index" do
      let!(:book1) { create(:book, title: "The Pragmatic Programmer", author: "Andy Hunt", genre: "Tech") }
      let!(:book2) { create(:book, title: "Clean Code", author: "Robert C. Martin", genre: "Tech") }
      let!(:book3) { create(:book, title: "Sapiens", author: "Yuval Noah Harari", genre: "History") }
      let!(:book4) { create(:book, title: "Sapiens 2", author: "Yuval Noah Harari", genre: "History") }

      context "without search query" do
        it "returns all books" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(assigns(:books)).to match_array([ book1, book2, book3, book4 ])
        end
      end

      context "with matching search query" do
        it "returns filtered books" do
          get :index, params: { query: "Clean" }
          expect(assigns(:books).pluck(:id)).to contain_exactly(book2.id)
        end

        it "returns multiple filtered books" do
          get :index, params: { query: "History" }
          expect(assigns(:books).pluck(:id)).to contain_exactly(book3.id, book4.id)
        end
      end

      context "with no matches" do
        it "returns empty result" do
          get :index, params: { query: "Nonexistent" }
          expect(assigns(:books)).to be_blank
        end
      end
    end

    describe "POST #create" do
      let(:valid_params) do
        {
          book: attributes_for(:book)
        }
      end

      it "creates a new book" do
        expect {
          post :create, params: valid_params
        }.to change(Book, :count).by(1)

        expect(response).to redirect_to(books_path)
        expect(flash[:notice]).not_to be_blank
      end
    end

    describe "PATCH #update" do
    let(:book) { create(:book, title: "Original Title") }

    context "with valid parameters" do
      it "updates the book and redirects to index" do
        patch :update, params: {
          id: book.id,
          book: { title: "Updated Title" }
        }

        expect(response).to redirect_to(books_path)
        expect(flash[:notice]).to eq("Book updated successfully.")
        expect(book.reload.title).to eq("Updated Title")
      end
    end

    context "with invalid parameters" do
      it "does not update the book and re-renders edit" do
        patch :update, params: {
          id: book.id,
          book: { title: "" }
        }

        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq("Ops... Please check possible errors")
        expect(book.reload.title).to eq("Original Title")
      end
    end

    context "with nonexistent book ID" do
      it "redirects to books_path with alert" do
        patch :update, params: {
          id: 999999,
          book: { title: "Any" }
        }

        expect(response).to redirect_to(books_path)
        expect(flash[:alert]).to eq("Ops... Book not found")
      end
    end
  end


    describe "GET #new" do
      it "assigns a new Book instance" do
        get :new
        expect(assigns(:book)).to be_a_new(Book)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "DELETE #destroy" do
      let!(:book) { create(:book) }

      it "deletes the book" do
        expect {
          delete :destroy, params: { id: book.id }
        }.to change(Book, :count).by(-1)

        expect(response).to redirect_to(books_path)
      end
    end

    describe "POST #create" do
      context "with valid parameters" do
        let(:valid_params) do
          {
            book: {
              title: "Refactoring",
              author: "Martin Fowler",
              genre: "Tech",
              isbn: "9780201485677",
              total_copies: 3
            }
          }
        end

        it "creates a new book and redirects to index" do
          expect {
            post :create, params: valid_params
          }.to change(Book, :count).by(1)

          expect(response).to redirect_to(books_path)
          expect(flash[:notice]).not_to be_blank
        end
      end

      context "with invalid parameters" do
        let(:invalid_params) do
          {
            book: {
              title: "",
              author: "",
              genre: "",
              isbn: "",
              total_copies: 0
            }
          }
        end

        it "does not create a book and re-renders new with alert" do
          expect {
            post :create, params: invalid_params
          }.not_to change(Book, :count)

          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:alert]).to be_present
        end
      end
    end
  end

  describe "as member" do
    let(:user_member) { create(:user, :member) }

    before do
      sign_in user_member
    end

    describe "GET #new" do
      it "redirects to root with alert" do
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).not_to be_blank
      end
    end

    describe "POST #create" do
      it "does not allow creating a book" do
        expect {
          post :create, params: { book: attributes_for(:book) }
        }.not_to change(Book, :count)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).not_to be_blank
      end
    end

    describe "PATCH #update" do
      let(:book) { create(:book) }

      it "does not allow updating a book" do
        patch :update, params: { id: book.id, book: { title: "New" } }

        expect(book.reload.title).not_to eq("New")
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).not_to be_blank
      end
    end

    describe "DELETE #destroy" do
      let!(:book) { create(:book) }

      it "does not allow deleting a book" do
        expect {
          delete :destroy, params: { id: book.id }
        }.not_to change(Book, :count)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).not_to be_blank
      end
    end
  end

  describe "PATCH #return_book" do
    let(:user_librarian) { create(:user, :librarian) }
    let(:user_member) { create(:user, :member) }
    let(:book) { create(:book) }

    before { sign_in user_librarian }

    context "when a borrowing exists and librarian is valid" do
      let!(:borrowing) { create(:borrowing, user: user_member, book: book) }

      it "marks the book as returned" do
        patch :return_book, params: { id: book.id, user_id: user_member.id }

        expect(response).to redirect_to(books_path)
        expect(flash[:notice]).to eq("Book returned successfully.")
        expect(borrowing.reload.returned_at).to be_present
      end
    end

    context "when doesnt have a user" do
      it "does not mark anything and shows alert" do
        patch :return_book, params: { id: book.id, user_id: -1 }

        expect(response).to redirect_to(books_path)
        expect(flash[:alert]).to eq("Cant return a book without user.")
      end
    end

    context "when no active borrowing exists" do
      let(:fake_user) { create(:user) }
      it "does not mark anything and shows alert" do
        patch :return_book, params: { id: book.id, user_id: fake_user.id }

        expect(response).to redirect_to(books_path)
        expect(flash[:alert]).to eq("Could not return the book.")
      end
    end

    context "when user is not librarian" do
      before do
        sign_in user_member
        create(:borrowing, user: user_member, book: book)
      end

      it "does not return the book" do
        patch :return_book, params: { id: book.id }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end
  end

  describe "POST #borrow" do
    let(:user_member) { create(:user, :member) }
    let(:book) { create(:book, total_copies: 1) }

    before do
      sign_in user_member
      allow(Current).to receive(:user).and_return(user_member)
    end

    context "when book is available for the user" do
      it "creates a borrowing and redirects with notice" do
        expect {
          post :borrow, params: { id: book.id }
        }.to change(Borrowing, :count).by(1)

        expect(response).to redirect_to(books_path)
        expect(flash[:notice]).to eq("Book borrowed successfully")
      end
    end

    context "when user already borrowed the book" do
      before do
        create(:borrowing, book: book, user: user_member, returned_at: nil)
      end

      it "does not create a borrowing and redirects with alert" do
        expect {
          post :borrow, params: { id: book.id }
        }.not_to change(Borrowing, :count)

        expect(response).to redirect_to(books_path)
        expect(flash[:alert]).to eq("Ops... Cant borrow this Book")
      end
    end
  end
end
