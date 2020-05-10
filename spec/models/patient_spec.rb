require 'rails_helper'

RSpec.describe Patient, type: :model do

  describe 'Validations' do
    it 'Create a Patient' do
      patient = build(:patient)
      expect(patient).to be_valid
    end

    it 'Create a Patient with medicament managements' do
      patient = build(:patient, :with_medicament_managements)
      expect(patient).to be_valid
      expect(patient.medicaments.length).to be_equal(2)
    end

    it 'Create a Patient without name attribute' do
      patient = build(:patient, name: nil)
      expect(patient).to be_invalid
    end

    it 'Create a Patient without cpf attribute' do
      patient = build(:patient, cpf: nil)
      expect(patient).to be_invalid
    end
  end

end
