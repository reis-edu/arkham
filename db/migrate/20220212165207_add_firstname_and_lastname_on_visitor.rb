# frozen_string_literal: true

class AddFirstnameAndLastnameOnVisitor < ActiveRecord::Migration[7.0]
  def change
    add_column :visitors, :firsname, :text
    add_column :visitors, :lastname, :text
    remove_column :visitors, :username
  end
end
