FactoryBot.define do
  factory :medicament_management, class: 'MedicamentManagement' do
    quantity        { 50 }
    unit_quantity   { 'mg' }
    via             { 'oral' }
    description     { '1x ao dia' }
    patient         { Patient.first || association(:patient) }
    medicament      { Medicament.first || build(:medicament) }
  end
end
