# frozen_string_literal: true

class CreateVisitors < ActiveRecord::Migration[7.0]
  def change
    create_table :visitors, id: :uuid do |t|
      t.string :name
      t.string :username
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
