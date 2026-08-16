# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::SavePatientPhoto do
  let(:mock_photo) do
    double(
      'PatientPhoto',
      photo_url: 'https://storage.googleapis.com/mock-bucket/mock-photo.jpg',
      photo_key: 'mock-photo-key'
    )
  end
  let(:patient_repository) { instance_double('PatientRepository') }
  let(:patient_photo_repository) { instance_double('PatientPhotoRepository') }
  let(:use_case) { described_class.new(patient_repository, patient_photo_repository) }
  let(:patient_id) { 1 }
  let(:photo_params) do
    {
      photo_base64: 'base64_encoded_photo',
      photo_base64_format: 'jpeg'
    }
  end

  describe '#execute' do
    before do
      allow(patient_photo_repository).to receive(:save).and_return(mock_photo)
      allow(patient_repository).to receive(:update)
    end

    it 'saves the photo through the photo repository' do
      expect(patient_photo_repository).to receive(:save).with(
        patient_id,
        photo_params[:photo_base64],
        photo_params[:photo_base64_format]
      )

      use_case.execute(patient_id, photo_params)
    end

    it 'updates the patient with the resulting photo url and key' do
      expect(patient_repository).to receive(:update).with(
        patient_id,
        {
          photo_url: mock_photo.photo_url,
          photo_key: mock_photo.photo_key
        }
      )

      use_case.execute(patient_id, photo_params)
    end
  end
end
