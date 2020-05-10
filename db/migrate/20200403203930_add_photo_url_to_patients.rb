class AddPhotoUrlToPatients < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :photo_url, :string
  end
end
