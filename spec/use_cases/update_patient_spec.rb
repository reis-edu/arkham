require 'rails_helper'

RSpec.describe Arkham::UseCases::UpdatePatient do
  let(:mock_photo) do
    double(
      'PatientPhoto',
      photo_url: 'https://storage.googleapis.com/mock-bucket/mock-photo.jpg',
      photo_key: 'mock-photo-key'
    )
  end
  let(:patient_repository) { instance_double('PatientRepository', within_transaction: nil, find_by_cpf: instance_double('Arkham::Domain::Entities::Patient', id: '123')) }
  let(:patient_photo_repository) { instance_double('PatientPhotoRepository') }
  let(:use_case) { described_class.new(patient_repository, patient_photo_repository) }

  describe '#execute' do
    let(:patient_id) { 1 }
    let(:valid_params) do
      {
        firstname: 'John',
        lastname: 'Doe',
        cpf: '123.456.789-00',
        gender: 'm',
        birth_date: '1990-01-01'
      }
    end

    let(:expected_params) do
      {
        firstname: 'John',
        lastname: 'Doe',
        cpf: '123.456.789-00',
        gender: 'm',
        birth_date: '1990-01-01'
      }
    end

    context 'when patient exists' do
      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        allow(patient_repository).to receive(:update)
        allow(patient_repository).to receive(:find_by_cpf).and_return(nil)
        allow(patient_repository).to receive(:within_transaction) do |&block|
          block.call
        end
      end

      it 'updates the patient' do
        expect(patient_repository).to receive(:update).with(patient_id, expected_params)
        use_case.execute(patient_id, valid_params)
      end

      it 'returns the patient id' do
        expect(use_case.execute(patient_id, valid_params)).to eq(patient_id)
      end

      context 'when trying to update to an existing CPF' do
        let(:existing_patient) { double('Patient', id: 2) }

        before do
          allow(patient_repository).to receive(:find_by_cpf).with(valid_params[:cpf]).and_return(existing_patient)
        end

        it 'raises PatientAlreadyExistsError' do
          expect { use_case.execute(patient_id, valid_params) }.to raise_error(Arkham::Domain::Errors::PatientAlreadyExistsError)
        end
      end

      context 'when updating to own CPF' do
        let(:existing_patient) { double('Patient', id: patient_id) }

        before do
          allow(patient_repository).to receive(:find_by_cpf).with(valid_params[:cpf]).and_return(existing_patient)
        end

        it 'allows the update' do
          expect(patient_repository).to receive(:update).with(patient_id, expected_params)
          use_case.execute(patient_id, valid_params)
        end
      end
    end

    context 'when patient does not exist' do
      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(nil)
        allow(patient_repository).to receive(:within_transaction) do |&block|
          block.call
        end
      end

      it 'raises PatientNotFoundError' do
        expect { use_case.execute(patient_id, valid_params) }.to raise_error(Arkham::Domain::Errors::PatientNotFoundError)
      end
    end

    context 'when params are invalid' do
      context 'when params are empty' do
        let(:empty_params) { {} }

        before do
          allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
          allow(patient_repository).to receive(:within_transaction) do |&block|
            block.call
          end
        end

        it 'raises ApiValidationError' do
          expect { use_case.execute(patient_id, empty_params) }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
        end

        it 'preserves the detailed message and field errors on the raised exception' do
          use_case.execute(patient_id, empty_params)
        rescue Arkham::Validators::Errors::ApiValidationError => e
          expect(e.message).to match(/API validation failed/)
          expect(e.errors).to include(:firstname, :lastname, :cpf, :gender)
        end
      end

      context 'when params are nil' do
        before do
          allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        end

        it 'raises ArgumentError' do
          expect { use_case.execute(patient_id, nil) }.to raise_error(ArgumentError, 'Input must be a Hash. NilClass was given.')
        end
      end

      context 'when required fields are missing' do
        let(:missing_fields_params) { { firstname: 'John' } }

        before do
          allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        end

        it 'raises ApiValidationError' do
          expect { use_case.execute(patient_id, missing_fields_params) }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
        end
      end

      context 'when fields have invalid types' do
        let(:invalid_types_params) do
          {
            firstname: 123,
            lastname: 'Doe',
            cpf: '123.456.789-00',
            gender: 'm',
            birth_date: '1990-01-01'
          }
        end

        before do
          allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        end

        it 'raises ApiValidationError' do
          expect { use_case.execute(patient_id, invalid_types_params) }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
        end
      end

      context 'when fields have invalid values' do
        let(:invalid_values_params) do
          {
            firstname: '',
            lastname: '',
            cpf: 'invalid-cpf',
            gender: 'invalid-gender',
            birth_date: 'invalid-date'
          }
        end

        before do
          allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        end

        it 'raises ApiValidationError' do
          expect { use_case.execute(patient_id, invalid_values_params) }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
        end
      end
    end

    context 'when database transaction fails' do
      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        allow(patient_repository).to receive(:find_by_cpf).and_return(nil)
        allow(patient_repository).to receive(:update).and_raise(ActiveRecord::RecordInvalid.new(Patient.new))
        allow(patient_repository).to receive(:within_transaction) do |&block|
          block.call
        end
      end

      it 'raises ActiveRecord::RecordInvalid' do
        expect { use_case.execute(patient_id, valid_params) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when repository fails' do
      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        allow(patient_repository).to receive(:update).and_raise(StandardError.new('Database error'))
        allow(patient_repository).to receive(:within_transaction) do |&block|
          block.call
        end
      end

      it 'raises StandardError' do
        expect { use_case.execute(patient_id, valid_params) }.to raise_error(StandardError)
      end
    end

    context 'when photo is provided' do
      let(:params_with_photo) do
        valid_params.merge(
          photo: {
            photo_base64: 'base64_encoded_photo',
            photo_base64_format: 'jpeg'
          }
        )
      end

      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(double('Patient'))
        allow(patient_repository).to receive(:update)
        allow(patient_photo_repository).to receive(:save).and_return(mock_photo)
        allow(patient_repository).to receive(:update)
        allow(Arkham::Repository::Filebase::PatientPhoto).to receive(:new).and_return(mock_photo)
        allow(mock_photo).to receive(:valid?).and_return(true)
        allow(patient_repository).to receive(:find_by_cpf).and_return(nil)
        allow(patient_repository).to receive(:within_transaction) do |&block|
          block.call
        end
      end

      it 'processes the photo' do
        expect(patient_photo_repository).to receive(:save)
        use_case.execute(patient_id, params_with_photo)
      end

      it 'updates patient with photo information' do
        expect(patient_repository).to receive(:update).with(
          patient_id,
          {
            photo_url: 'https://storage.googleapis.com/mock-bucket/mock-photo.jpg',
            photo_key: 'mock-photo-key'
          }
        )
        use_case.execute(patient_id, params_with_photo)
      end

      context 'when photo is invalid' do
        before do
          allow(mock_photo).to receive(:valid?).and_return(false)
        end

        it 'logs the error but continues processing' do
          expect(mock_photo).not_to receive(:save)
          expect(use_case.execute(patient_id, params_with_photo)).to eq(patient_id)
        end
      end
    end

    context 'when remove_photo is true' do
      let(:params_with_remove_photo) { valid_params.merge(remove_photo: true) }
      let(:patient_double) { double('Patient', photo_key: 'mock-photo-key') }

      before do
        allow(patient_repository).to receive(:find_by_id).with(patient_id).and_return(patient_double)
        allow(patient_repository).to receive(:update)
        allow(patient_repository).to receive(:find_by_cpf).and_return(nil)
        allow(patient_photo_repository).to receive(:delete)
        allow(patient_repository).to receive(:within_transaction) do |&block|
          block.call
        end
      end

      it 'deletes the photo from storage' do
        expect(patient_photo_repository).to receive(:delete).with('mock-photo-key')
        use_case.execute(patient_id, params_with_remove_photo)
      end

      it 'clears photo_url and photo_key on the patient' do
        expect(patient_repository).to receive(:update).with(patient_id, expected_params)
        expect(patient_repository).to receive(:update).with(patient_id, photo_url: nil, photo_key: nil)
        use_case.execute(patient_id, params_with_remove_photo)
      end

      it 'does not attempt to save a new photo' do
        expect(patient_photo_repository).not_to receive(:save)
        use_case.execute(patient_id, params_with_remove_photo)
      end
    end
  end
end
