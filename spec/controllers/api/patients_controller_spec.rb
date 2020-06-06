# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PatientsController, type: :controller do
  describe 'POST #create' do
    patient = JSON.parse(File.read('spec/fixtures/patient/patient.json'))

    context 'when everything goes well' do
      subject { post :create, params: { patient: patient } }

      it 'should be success!' do
        subject
        expect(response.status).to eq(200)
      end
    end

    context 'when payload received has invalid attributes' do
      subject { post :create, params: { patient: patient.reject { |k, _v| k == 'firstname' } } }

      it 'should fail!' do
        subject
        expect(response.status).to eq(422)
      end
    end

    context 'when there is already a patient with the same CPF' do
      subject { post :create, params: { patient: patient } }

      it 'should fail!' do
        create(:patient)
        subject
        expect(response.status).to eq(422)
      end
    end
  end
end
