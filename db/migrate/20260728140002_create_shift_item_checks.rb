class CreateShiftItemChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :shift_item_checks, id: :uuid do |t|
      t.uuid :shift_id, null: false
      t.uuid :shift_item_id, null: false
      t.boolean :checked, null: false, default: false
      t.uuid :checked_by_id
      t.datetime :checked_at
      t.boolean :impossible, null: false, default: false
      t.text :impossible_reason
      t.string :review_status, null: false, default: 'pending'
      t.uuid :reviewed_by_id
      t.datetime :reviewed_at
      t.text :divergence_note
      t.timestamps
    end
    add_index :shift_item_checks, %i[shift_id shift_item_id], unique: true
    add_foreign_key :shift_item_checks, :shifts
    add_foreign_key :shift_item_checks, :shift_items
    add_foreign_key :shift_item_checks, :users, column: :checked_by_id
    add_foreign_key :shift_item_checks, :users, column: :reviewed_by_id
  end
end
