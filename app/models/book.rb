# frozen_string_literal: true

class Book < ApplicationRecord
  validates :title, :author, :genre, :isbn, :total_copies, presence: true
  validates :total_copies, numericality: { only_integer: true, greater_than: 0 }
end
