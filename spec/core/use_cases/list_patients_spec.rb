# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::Core::UseCases::ListPatients do
  let(:patient_repository) { instance_double('PatientRepository') }
  let(:use_case) { described_class.new(patient_repository) }

  describe '#execute' do
    let(:filter_params) { { status: 'active' } }
    let(:expected_patients) { [double('Patient'), double('Patient')] }

    context 'when repository succeeds' do
      before do
        allow(patient_repository).to receive(:find_all).with(filter_params).and_return(expected_patients)
      end

      it 'returns all patients' do
        expect(use_case.execute(filter_params)).to eq(expected_patients)
      end

      it 'calls repository with filter params' do
        expect(patient_repository).to receive(:find_all).with(filter_params)
        use_case.execute(filter_params)
      end

      context 'when no filter params are provided' do
        it 'calls repository with empty hash' do
          expect(patient_repository).to receive(:find_all).with({})
          use_case.execute
        end
      end
    end

    context 'when repository fails' do
      before do
        allow(patient_repository).to receive(:find_all).and_raise(StandardError.new('Database error'))
      end

      it 'raises StandardError' do
        expect { use_case.execute(filter_params) }.to raise_error(StandardError)
      end
    end

    context 'when filter params are invalid' do
      let(:invalid_filter_params) { { status: nil } }

      before do
        allow(patient_repository).to receive(:find_all).and_raise(ArgumentError.new('Invalid filter'))
      end

      it 'raises ArgumentError' do
        expect { use_case.execute(invalid_filter_params) }.to raise_error(ArgumentError)
      end
    end
  end
end
