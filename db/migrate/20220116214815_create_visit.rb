
class CreateVisit < ActiveRecord::Migration[7.0]
  def change
    create_table :visits, id: :uuid do |t|
      t.uuid      :patient_id, null: false, foreign_key: true
      t.uuid      :visitor_id, null: false, foreign_key: true
      t.datetime  :start_date, null: false
      t.datetime  :end_date, null: false
      t.text      :description
      t.timestamps
    end
  end
end
