class RemoveFullnameOnVisitors < ActiveRecord::Migration[7.0]
  def change
    remove_column :visitors, :fullname
  end
end
