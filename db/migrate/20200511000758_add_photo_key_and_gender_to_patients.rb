# frozen_string_literal: true

class AddPhotoKeyAndGenderToPatients < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :photo_key, :string
    add_column :patients, :gender, :string
  end
end
