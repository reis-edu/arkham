
class CreateMedicaments < ActiveRecord::Migration[6.0]
  def change
    create_table :medicaments, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
