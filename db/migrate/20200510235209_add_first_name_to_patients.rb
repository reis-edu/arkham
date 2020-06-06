# frozen_string_literal: true

class AddFirstNameToPatients < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :firstname, :string
    add_column :patients, :lastname, :string
    add_column :patients, :fullname, :string
    remove_column :patients, :name, :string
  end
end
