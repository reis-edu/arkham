# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::Core::UseCases::DestroyPatient do
  let(:patient_repository) { instance_double('PatientRepository') }
  let(:use_case) { described_class.new(patient_repository) }

  describe '#execute' do
    let(:patient_id) { 1 }

    context 'when patient exists' do
      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        allow(patient_repository).to receive(:destroy)
      end

      it 'destroys the patient' do
        expect(patient_repository).to receive(:destroy).with(patient_id)
        use_case.execute(patient_id)
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

    context 'when repository fails' do
      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        allow(patient_repository).to receive(:destroy).and_raise(StandardError.new('Database error'))
      end

      it 'raises StandardError' do
        expect { use_case.execute(patient_id) }.to raise_error(StandardError)
      end
    end
  end
end
