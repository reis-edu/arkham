# frozen_string_literal: true

class RemoveNameOnVisitors < ActiveRecord::Migration[7.0]
  def change
    remove_column :visitors, :name
  end
end
