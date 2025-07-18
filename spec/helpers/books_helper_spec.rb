require "rails_helper"

RSpec.describe BooksHelper, type: :helper do
  let(:user_member) { create(:user, :member) }
  let(:book) { create(:book, total_copies: 2) }

  before do
    Current.session = create(:session, user: user_member)
  end

  describe "#can_borrow_book?" do
    it "returns true when user is member and book is available" do
      allow(helper).to receive(:member?).and_return(true)
      allow(book).to receive(:available_for?).with(user_member).and_return(true)

      expect(helper.can_borrow_book?(book)).to be true
    end

    it "returns false if user is not member" do
      allow(helper).to receive(:member?).and_return(false)
      expect(helper.can_borrow_book?(book)).to be false
    end

    it "returns false if book is not available for user" do
      allow(helper).to receive(:member?).and_return(true)
      allow(book).to receive(:available_for?).with(user_member).and_return(false)
      expect(helper.can_borrow_book?(book)).to be false
    end
  end

  describe "#available_copies?" do
    it "returns true when available copies > 0" do
      expect(helper.available_copies?(book)).to be true
    end

    it "returns false when no available copies" do
      allow(book).to receive(:available_copies).and_return(0)
      expect(helper.available_copies?(book)).to be false
    end
  end

  describe "#already_borrowred?" do
    it "returns true if user has borrowing record" do
      create(:borrowing, book: book, user: user_member)
      expect(helper.already_borrowred?(book)).to be true
    end

    it "returns false if user has not borrowed the book" do
      expect(helper.already_borrowred?(book)).to be false
    end
  end

  describe "#borrowed_on" do
    it "returns formatted borrowed date" do
      borrowing = create(:borrowing, user: user_member, book: book)
      expect(helper.borrowed_on(borrowing)).to eq(I18n.l(borrowing.borrowed_at, format: :long))
    end
  end

  describe "#due_on" do
    it "returns formatted due date" do
      borrowing = create(:borrowing, user: user_member, book: book)
      expect(helper.due_on(borrowing)).to eq(I18n.l(borrowing.due_at, format: :long))
    end
  end

  describe "#returned_on" do
    it "returns formatted return date if returned" do
      borrowing = create(:borrowing, user: user_member, book: book)
      borrowing.update_attribute(:returned_at, Time.zone.local(2025, 7, 10, 12))
      expect(helper.returned_on(borrowing)).to eq(I18n.l(borrowing.returned_at, format: :long))
    end

    it "returns nil if not returned" do
      borrowing = create(:borrowing, user: user_member, book: book, returned_at: nil)
      expect(helper.returned_on(borrowing)).to be_nil
    end
  end
end
