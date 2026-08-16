# frozen_string_literal: true

class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients, id: :uuid do |t|
      t.string  :name
      t.text    :diagnosis
      t.string  :sus
      t.string  :rg
      t.string  :cpf
      t.date    :admission_date
      t.date    :birth_date

      t.timestamps
    end
  end
end
