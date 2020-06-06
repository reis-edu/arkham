# frozen_string_literal: true

class RemoveFullnameFromPatients < ActiveRecord::Migration[6.0]
  def change
    remove_column :patients, :fullname
  end
end
