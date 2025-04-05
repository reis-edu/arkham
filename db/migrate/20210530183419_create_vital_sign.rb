
class CreateVitalSign < ActiveRecord::Migration[6.0]
  def change
    create_table :vital_signs, id: :uuid do |t|
      t.uuid      :patient_id, null: false, foreign_key: true
      t.string    :pa
      t.string    :period
      t.integer   :bpm
      t.integer   :saturation
      t.string    :blood_glucose
      t.float     :temperature
      t.date      :date

      t.timestamps
    end
  end
end
