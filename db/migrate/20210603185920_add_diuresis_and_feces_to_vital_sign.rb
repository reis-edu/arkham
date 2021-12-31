# frozen_string_literal: true

class AddDiuresisAndFecesToVitalSign < ActiveRecord::Migration[6.0]
  def change
    add_column :vital_signs, :diuresis, :string
    add_column :vital_signs, :feces, :string
  end
end
