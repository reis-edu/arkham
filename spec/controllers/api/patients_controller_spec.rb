# frozen_string_literal: true

require 'rails_helper'
require 'google/cloud/storage'

RSpec.describe Api::PatientsController, type: :controller do

  describe 'GET #index' do
    context 'when everything goes well' do
      subject { get :index, format: :json }

      render_views
      it 'is success!' do
        create(:patient)
        subject
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['patients'].count).to be 1
      end
    end
  end

  describe 'POST #create' do
    patient = JSON.parse(File.read('spec/fixtures/patient/patient.json'))

    context 'when payload has no photo', :vcr do
      context 'and everything goes well' do
        subject { post :create, params: { patient: patient } }

        it 'is success!' do
          subject
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['id']).should_not be_nil
          expect(Patient.find(JSON.parse(response.body)['id']).active?).to be true
        end
      end

      context 'and payload received has invalid attributes' do
        subject { post :create, params: { patient: patient.reject { |k, _v| k == 'firstname' } } }

        it 'fails!' do
          subject
          expect(response.status).to eq(422)
        end
      end

      context 'and there is already a patient with the same CPF' do
        subject { post :create, params: { patient: patient } }

        it 'fails!' do
          create(:patient)
          subject
          expect(response.status).to eq(422)
        end
      end
    end

    context 'when payload has photo', :vcr do
      base64_image = File.open('spec/images/arkham.jpg', 'rb', &:read)
      patient['photo'] = {
        'photo_base64': base64_image,
        'photo_base64_format': 'png'
      }

      context 'and everything goes well' do
        subject { post :create, params: { patient: patient } }

        it 'it success!' do
          storage_file_instance = double(Google::Cloud::Storage::File, id: '123abc', public_url: '')
          allow_any_instance_of(Google::Cloud::Storage::Bucket)
            .to receive(:create_file).and_return(storage_file_instance)

          subject
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['id']).should_not be_nil
          expect(Patient.find(JSON.parse(response.body)['id']).photo_url).to eq nil
        end
      end

      context 'and payload photo has missing attributes' do
        patient['photo'] = {
          'photo_base64_format': 'png'
        }
        subject { post :create, params: { patient: patient } }

        it 'creates patient without photo' do
          subject
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['id']).should_not be_nil
          expect(Patient.find(JSON.parse(response.body)['id']).photo_url).to eq nil
        end
      end
    end
  end

  describe 'POST #activate' do
    context 'when everything goes well' do
      it 'updates patient status to active' do
        patient = create(:patient, status: 'inactive')
        post :activate, params: { id: patient.id }

        expect(response.status).to eq(200)
        expect(Patient.find(JSON.parse(response.body)['id']).active?).to be true
      end
    end
  end

  describe 'POST #inactivate' do
    context 'when everything goes well' do      
      it 'updates patient status to inactive' do
        patient = create(:patient)
        post :inactivate, params: { id: patient.id }

        expect(response.status).to eq(200)
        expect(Patient.find(JSON.parse(response.body)['id']).active?).to be false
      end
    end
  end
end
