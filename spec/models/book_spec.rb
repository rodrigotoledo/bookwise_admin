# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      book = build(:book)
      expect(book).to be_valid
    end

    it "is invalid without required attributes" do
      book = build(:book, title: nil, author: nil, genre: nil, isbn: nil, total_copies: nil)
      expect(book).not_to be_valid
      expect(book.errors[:title]).not_to be_blank
      expect(book.errors[:author]).not_to be_blank
      expect(book.errors[:genre]).not_to be_blank
      expect(book.errors[:isbn]).not_to be_blank
      expect(book.errors[:total_copies]).not_to be_blank
    end

    it "is invalid with total_copies less than 1" do
      book = build(:book, total_copies: 0)
      expect(book).not_to be_valid
      expect(book.errors[:total_copies]).to include("must be greater than 0")
    end
  end

  describe "availability" do
    let(:book) { create(:book, total_copies: 3) }
    let(:user_member1) { create(:user, :member) }
    let(:user_member2) { create(:user, :member) }
    let(:user_member3) { create(:user, :member) }
    let(:user_member4) { create(:user, :member) }
    describe "#available_copies" do
      it "returns correct count when no borrowings" do
        expect(book.available_copies).to eq(3)
      end

      it "returns correct count with active borrowings" do
        create(:borrowing, book: book, user: user_member1)
        expect(book.available_copies).to eq(2)
      end

      it "ignores returned borrowings" do
        create(:borrowing, book: book, user: user_member1, returned_at: Time.current)
        expect(book.available_copies).to eq(3)
      end
    end

    describe "#available_for?" do
      it "returns true if user has no active borrowing and copies available" do
        expect(book.available_for?(user_member1)).to be true
      end

      it "returns false if user already borrowed the book and hasn't returned" do
        create(:borrowing, book: book, user: user_member1)
        expect(book.available_for?(user_member1)).to be false
      end

      it "returns true if user had borrowed and returned the book" do
        create(:borrowing, book: book, user: user_member1, returned_at: Time.current)
        expect(book.available_for?(user_member1)).to be true
      end

      context "when dont have copies" do
        let(:book) { create(:book, total_copies: 3) }
        let(:user_member1) { create(:user, :member) }
        let(:user_member2) { create(:user, :member) }
        let(:user_member3) { create(:user, :member) }
        let(:user_member4) { create(:user, :member) }
        it "returns false if no copies are available" do
          borrowing1 = create(:borrowing, book: book, user: user_member1)
          borrowing2 = create(:borrowing, book: book, user: user_member2)
          borrowing3 = create(:borrowing, book: book, user: user_member3)
          invalid_borrowing = build(:borrowing, book: book, user: user_member4)
          expect(borrowing1).to be_persisted
          expect(borrowing2).to be_persisted
          expect(borrowing3).to be_persisted
          expect(invalid_borrowing).not_to be_valid
        end
      end
    end
  end

  describe "#borrowed_by?" do
    let(:book) { create(:book) }
    let(:user_member) { create(:user, :member) }
    let(:fake_member) { create(:user, :member) }


    context "when the user has an active borrowing for the book" do
      let!(:borrowing) {create(:borrowing, book: book, user: user_member, returned_at: nil)}
      it "returns true" do
        expect(book.borrowed_by?(user: user_member, borrowing: borrowing)).to be true
      end
    end

    context "when the user has returned the book" do
      let!(:borrowing) {create(:borrowing, book: book, user: user_member, returned_at: Time.current)}

      it "returns false" do
        expect(book.borrowed_by?(user: user_member, borrowing: borrowing)).to be false
      end
    end

    context "when the user has never borrowed the book" do
      let!(:borrowing) {create(:borrowing, book: book, user: user_member, returned_at: nil)}
      it "returns true" do
        expect(book.borrowed_by?(user: fake_member, borrowing: borrowing)).not_to be_truthy
      end
    end
  end

  describe "#borrowed_by" do
    let(:book) { create(:book) }
    let(:user_member) { create(:user, :member) }
    let(:fake_member) { create(:user, :member) }

    context "when the user has an active borrowing for the book" do
      before do
        create(:borrowing, book: book, user: user_member, returned_at: nil)
      end

      it "returns true" do
        expect(book.borrowed_by(user: user_member)).to be_truthy
      end
    end

    context "when the user has returned the book" do
      before do
        create(:borrowing, book: book, user: user_member, returned_at: Time.current)
      end

      it "when the user doenst have active_borrowings" do
        expect(book.borrowed_by(user: user_member)).not_to be_empty
      end
    end

    context "when the user has never borrowed the book" do
      it "returns false" do
        expect(book.borrowed_by(user: fake_member)).to be_empty
      end
    end
  end
end
