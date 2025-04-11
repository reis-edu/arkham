require 'rails_helper'

RSpec.describe Arkham::UseCases::ListPatients do
  let(:use_case) { described_class.new(patient_repository) }

  describe '#execute' do
    let(:filter_params) { { status: 'active' } }
    let(:expected_patients) { [double('Patient'), double('Patient')] }

    context 'when repository succeeds' do
      let(:patient_repository) { instance_double('PatientRepository') }

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
      let(:patient_repository) { instance_double('PatientRepository') }

      before do
        allow(patient_repository).to receive(:find_all).and_raise(StandardError.new('Database error'))
      end

      it 'raises StandardError' do
        expect { use_case.execute(filter_params) }.to raise_error(StandardError)
      end
    end

    context 'when filter params are invalid' do
      let(:patient_repository) { instance_double('PatientRepository') }
      let(:invalid_filter_params) { { status: nil } }

      before do
        allow(patient_repository).to receive(:find_all).and_raise(ArgumentError.new('Invalid filter'))
      end

      it 'raises ArgumentError' do
        expect { use_case.execute(invalid_filter_params) }.to raise_error(ArgumentError)
      end
    end

    context 'when filter params are valid' do
      let(:patient_repository) { Arkham::Repository::ActiveRecord::PatientRepository.new }

      context 'with active status' do
        let(:filter_params) { { status: 'active' } }
  
        before do
          create(:patient)
          create(:patient, status: 'inactive')
        end
  
        it 'returns patients' do
          patients = use_case.execute(filter_params)
  
          expect(patients.count).to eq 1
        end
      end

      context 'with inactive status' do
        let(:filter_params) { { status: 'inactive' } }
  
        before do
          create(:patient)
          create(:patient, firstname: 'Paciente', lastname: 'Inativo', status: 'inactive')
        end
  
        it 'returns patients' do
          patients = use_case.execute(filter_params)
  
          expect(patients.count).to eq 1
          expect(patients.first.fullname).to eq 'Paciente Inativo'
        end
      end

      context 'with search term without accent' do
        let(:filter_params) { { search_term: 'joao' } }
  
        before do
          create(:patient, firstname: 'João', lastname: 'Pessoa')
          create(:patient, firstname: 'Paciente', lastname: 'Inativo', status: 'inactive')
        end
  
        it 'returns patients' do
          patients = use_case.execute(filter_params)
  
          expect(patients.count).to eq 1
          expect(patients.first.fullname).to eq 'João Pessoa'
        end
      end

      context 'with search term with accent' do
        let(:filter_params) { { search_term: 'joão' } }
  
        before do
          create(:patient, firstname: 'Joao', lastname: 'Pessoa')
          create(:patient, firstname: 'Paciente', lastname: 'Inativo', status: 'inactive')
        end
  
        it 'returns patients' do
          patients = use_case.execute(filter_params)
  
          expect(patients.count).to eq 1
          expect(patients.first.fullname).to eq 'Joao Pessoa'
        end
      end

      context 'with empty search term' do
        let(:filter_params) { { search_term: '' } }
  
        before do
          create(:patient, firstname: 'Joao', lastname: 'Pessoa')
          create(:patient, firstname: 'Paciente', lastname: 'Inativo')
        end
  
        it 'returns patients' do
          patients = use_case.execute(filter_params)
  
          expect(patients.count).to eq 2
        end
      end

      context 'with not found search term' do
        let(:filter_params) { { search_term: 'Pedro' } }
  
        before do
          create(:patient, firstname: 'Joao', lastname: 'Pessoa')
          create(:patient, firstname: 'Paciente', lastname: 'Inativo')
        end
  
        it 'do not returns patients' do
          patients = use_case.execute(filter_params)
  
          expect(patients.count).to eq 0
        end
      end
    end
  end
end
