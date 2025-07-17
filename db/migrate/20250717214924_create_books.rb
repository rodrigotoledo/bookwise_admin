# frozen_string_literal: true

class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string  :title, null: false
      t.string  :author, null: false
      t.string  :genre, null: false
      t.string  :isbn, null: false
      t.integer :total_copies, null: false

      t.timestamps
    end
  end
end
