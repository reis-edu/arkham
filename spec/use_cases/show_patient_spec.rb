require 'rails_helper'

RSpec.describe Arkham::UseCases::ShowPatient do
  let(:patient_repository) { instance_double('PatientRepository') }
  let(:use_case) { described_class.new(patient_repository) }

  describe '#execute' do
    let(:patient_id) { 1 }
    let(:patient) { double('Patient') }

    context 'when patient exists' do
      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(patient)
      end

      it 'returns the patient' do
        expect(use_case.execute(patient_id)).to eq(patient)
      end
    end

    context 'when patient does not exist' do
      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(nil)
      end

      it 'raises PatientNotFoundError' do
        expect { use_case.execute(patient_id) }.to raise_error(Arkham::Domain::Errors::PatientNotFoundError)
      end
    end
  end
end 