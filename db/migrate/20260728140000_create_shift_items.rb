# frozen_string_literal: true

class CreateShiftItems < ActiveRecord::Migration[8.0]
  def change
    create_table :shift_items, id: :uuid do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :shift_items, :name, unique: true
  end
end
