# frozen_string_literal: true

class AllowMultipleShiftsPerDateAndTypeAndAddTitle < ActiveRecord::Migration[8.0]
  def change
    remove_index :shifts, %i[shift_date shift_type], unique: true
    add_index :shifts, %i[shift_date shift_type]
    add_column :shifts, :title, :string
  end
end
