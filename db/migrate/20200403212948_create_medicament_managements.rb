class CreateMedicamentManagements < ActiveRecord::Migration[6.0]
  def change
    create_table :medicament_managements, id: :uuid do |t|
      t.uuid :medicament_id, null: false, foreign_key: true
      t.uuid :patient_id, null: false, foreign_key: true
      t.integer :quantity
      t.string :unit_quantity
      t.string :via
      t.text   :description

      t.timestamps
    end
  end
end
