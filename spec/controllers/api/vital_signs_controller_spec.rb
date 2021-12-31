# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::VitalSignsController, type: :controller do
  describe 'POST #create' do
    context 'success' do
      subject { post :create, params: { patient_id: Patient.take.id, date: Time.zone.today.to_s, period: 'morning' } }

      it 'is success!' do
        create(:patient)
        subject
        expect(response.status).to eq(200)
      end
    end

    context 'error' do
      context 'When POST without period' do
        subject { post :create, params: { patient_id: Patient.take.id, date: Time.zone.today.to_s } }

        it 'returns 422' do
          create(:patient)
          subject
          expect(response.status).to eq(422)
        end
      end

      context 'When POST with invalid period' do
        subject do
          post :create, params: {
            patient_id: Patient.take.id,
            date: Time.zone.today.to_s,
            period: 'afternoon'
          }
        end

        it 'raises VitalSignPeriodNotFoundError' do
          create(:patient)
          expect { subject }.to raise_error(Core::Errors::VitalSign::VitalSignPeriodNotFoundError, 'Period not found')
        end
      end

      context 'When Vital Sign already exist' do
        subject do
          post :create, params: {
            patient_id: Patient.take.id,
            date: Date.new(2021, 5, 30).to_s,
            period: 'morning'
          }
        end

        it 'raises VitalSignPeriodNotFoundError' do
          create(:patient)
          create(:vital_sign)

          expect { subject }.to raise_error(
            Core::Errors::VitalSign::VitalSignAlreadyExistsError,
            'Vital Sign already exist'
          )
        end
      end
    end
  end
end
