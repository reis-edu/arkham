class CreateShifts < ActiveRecord::Migration[8.0]
  def change
    create_table :shifts, id: :uuid do |t|
      t.date :shift_date, null: false
      t.string :shift_type, null: false
      t.string :status, null: false, default: 'open'
      t.text :execution_note
      t.datetime :execution_finalized_at
      t.uuid :execution_finalized_by_id
      t.datetime :review_finalized_at
      t.uuid :review_finalized_by_id
      t.timestamps
    end
    add_index :shifts, %i[shift_date shift_type], unique: true
    add_foreign_key :shifts, :users, column: :execution_finalized_by_id
    add_foreign_key :shifts, :users, column: :review_finalized_by_id
  end
end
