# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, type: :model do
  it "is valid with valid attributes" do
    book = build(:book)
    expect(book).to be_valid
  end

  it "is invalid without required attributes" do
    book = build(:book, title: nil, author: nil, genre: nil, isbn: nil)
    expect(book).not_to be_valid
    expect(book.errors[:title]).not_to be_empty
    expect(book.errors[:author]).not_to be_empty
  end

  it "is invalid with total_copies less than 1" do
    book = build(:book, total_copies: 0)
    expect(book).not_to be_valid
    expect(book.errors[:total_copies]).to include("must be greater than 0")
  end
end
