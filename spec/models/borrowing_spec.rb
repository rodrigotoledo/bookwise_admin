# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  let(:user_member) { create(:user, :member) }
  let(:user_member2) { create(:user, :member) }
  let(:user_member3) { create(:user, :member) }
  let(:user_member4) { create(:user, :member) }
  let(:book) { create(:book, total_copies: 3) }

  describe "validations" do
    it "is valid with valid attributes" do
      borrowing = build(:borrowing, user: user_member, book: book)
      expect(borrowing).to be_valid
    end

    it "is invalid if due_at is before or equal to borrowed_at" do
      borrowing = build(:borrowing, borrowed_at: Time.current, due_at: 1.day.ago)
      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:due_at]).to include("must be after the borrowing date")
    end
  end

  describe "automatic dates" do
    it "sets borrowed_at and due_at on create" do
      borrowing = create(:borrowing, user: user_member, book: book)
      expect(borrowing.borrowed_at).to be_present
      expect(borrowing.due_at).to eq(borrowing.borrowed_at + 2.weeks)
    end
  end

  describe "uniqueness of active borrowing" do
    it "does not allow a second active borrowing for the same user and book" do
      create(:borrowing, user: user_member, book: book)
      duplicate = build(:borrowing, user: user_member, book: book)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:book_id]).to include("has already been borrowed and not yet returned")
    end

    it "allows borrowing again after returning the previous one" do
      past_borrowing = create(:borrowing, user: user_member, book: book, returned_at: Time.current)
      new_borrowing = build(:borrowing, user: user_member, book: book)

      expect(new_borrowing).to be_valid
    end

    it "allows borrowing with other user" do
      create(:borrowing, user: user_member, book: book)
      new_borrowing = build(:borrowing, user: user_member2, book: book)

      expect(new_borrowing).to be_valid
    end

    it "does not allow borrowing with dont have copies" do
      create(:borrowing, user: user_member, book: book)
      create(:borrowing, user: user_member2, book: book)
      create(:borrowing, user: user_member3, book: book)
      new_borrowing = build(:borrowing, user: user_member4, book: book)

      expect(new_borrowing).not_to be_valid
    end
  end

  describe ".return_for" do
    let(:user_librarian) { create(:user, :librarian) }
    let(:user_member) { create(:user, :member) }
    let(:book) { create(:book) }
    let!(:borrowing) { create(:borrowing, user: user_member, book: book) }

    context "when called by a librarian" do
      it "marks the book as returned" do
        result = Borrowing.return_for(librarian: user_librarian, user: user_member, book: book)
        expect(result).to be_truthy
        expect(borrowing.reload.returned_at).to be_present
      end
    end

    context "when called by a non-librarian" do
      it "does not mark the book as returned" do
        result = Borrowing.return_for(librarian: user_member, user: user_member, book: book)
        expect(result).to be false
        expect(borrowing.reload.returned_at).to be_nil
      end
    end

    context "when no active borrowing exists" do
      it "returns false" do
        Borrowing.return_for(librarian: user_librarian, user: :user_member, book: book)
        result = Borrowing.return_for(librarian: user_librarian, user: :user_member, book: book)
        expect(result).to be false
      end
    end
  end
end
