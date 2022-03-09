class RemoveFirsnameFromVisitors < ActiveRecord::Migration[7.0]
  def change
    add_column :visitors, :firstname, :text
    remove_column :visitors, :firsname
  end
end
