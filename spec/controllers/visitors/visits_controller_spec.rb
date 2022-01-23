# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Visitors::VisitsController, type: :controller do
  describe 'GET #index' do
    context 'Success' do
      context 'When visitor has visits' do
        before do
          patient = create(:patient)
          visitor = create(:visitor)
          create(:visit, patient_id: patient.id, visitor_id: visitor.id)
          allow(JsonWebToken).to receive(:decode)
            .and_return({ visitor_id: visitor.id })
        end

        subject do
          get :index, format: :json
        end

        render_views
        it 'returns visitor visits' do
          subject
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['visits'].count).to be 1
        end
      end
    end

    context 'Error' do
      context 'When request is unauthorized' do
        subject do
          get :index
        end

        it 'returns unauthorized message error' do
          subject
          expect(response.status).to eq(401)
        end
      end
    end
  end

  describe 'GET #show' do
    let(:patient) { create(:patient) }
    let(:visitor) { create(:visitor) }
    let(:visit) { create(:visit, patient_id: patient.id, visitor_id: visitor.id) }

    context 'Success' do
      context 'When visitor has visits' do
        before do
          allow(JsonWebToken).to receive(:decode)
            .and_return({ visitor_id: visitor.id })
        end

        subject do
          get :show, params: { id: visit.id }, format: :json
        end

        render_views
        it 'returns visitor visit' do
          subject
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['visit']['description']).to eq 'My description'
        end
      end
    end

    context 'Error' do
      context 'When request is unauthorized' do
        subject do
          get :show, params: { id: visit.id }
        end

        it 'returns unauthorized message error' do
          subject
          expect(response.status).to eq(401)
        end
      end

      context 'When visit is not found' do
        before do
          allow(JsonWebToken).to receive(:decode)
            .and_return({ visitor_id: visitor.id })
        end

        subject do
          get :show, params: { id: '123' }
        end

        it 'returns unauthorized message error' do
          subject
          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe 'GET #visits_patients' do
    context 'Success' do
      before do
        patient = create(:patient)
        visitor = create(:visitor)
        create(:visit, patient_id: patient.id, visitor_id: visitor.id)
        allow(JsonWebToken).to receive(:decode)
          .and_return({ visitor_id: visitor.id })
      end

      subject do
        get :patients, format: :json
      end

      render_views
      it 'returns patients' do
        subject
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['patients'].count).to be 1
      end
    end

    context 'Error' do
      context 'When request is unauthorized' do
        subject do
          get :patients
        end

        it 'returns unauthorized message error' do
          subject
          expect(response.status).to eq(401)
        end
      end
    end
  end

  describe 'POST #create' do
    visit_json = JSON.parse(File.read('spec/fixtures/visit/visit.json'))

    context 'Success' do
      before do
        create(:patient)
        visitor = create(:visitor)
        allow(JsonWebToken).to receive(:decode)
          .and_return({ visitor_id: visitor.id })
      end

      subject do
        post :create, params: { visit: visit_json.merge(patient_id: Patient.take.id) }
      end

      it 'creates visit' do
        subject
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['id']).not_to be_nil
      end
    end

    context 'Error' do
      context 'When request is unauthorized' do
        subject do
          post :create, params: { visit: visit_json }
        end

        it 'returns unauthorized message error' do
          subject
          expect(response.status).to eq(401)
        end
      end

      context 'When has already a visit at same time' do
        before do
          patient = create(:patient)
          visitor = create(:visitor)
          create(:visit, patient_id: patient.id, visitor_id: visitor.id)
          allow(JsonWebToken).to receive(:decode)
            .and_return({ visitor_id: visitor.id })
        end

        subject do
          visit_json.merge!(patient_id: Patient.take.id,
                            start_date: Time.zone.now.to_s)
          post :create, params: { visit: visit_json }
        end

        it 'returns conflict message error' do
          subject
          expect(response.status).to eq(409)
        end
      end
    end
  end

  describe 'POST #update' do
    visit_json = JSON.parse(File.read('spec/fixtures/visit/visit.json'))

    context 'Success' do
      before do
        patient = create(:patient)
        visitor = create(:visitor)
        old_visit = create(:visit, patient_id: patient.id, visitor_id: visitor.id)
        create(:visit, patient_id: patient.id,
                       visitor_id: visitor.id,
                       start_date: old_visit.start_date + 41.minutes,
                       end_date: old_visit.end_date + 41.minutes)
        allow(JsonWebToken).to receive(:decode)
          .and_return({ visitor_id: visitor.id })
      end

      subject do
        current_visit = Visit.order(created_at: :desc).take
        new_attrs = { description: 'Updated description' }
        post :update, params: { id: current_visit.id,
                                visit: JSON.parse(current_visit.to_json).merge(new_attrs) }
      end

      it 'updates visit' do
        subject
        expect(response.status).to eq(200)
        expect(Visit.order(created_at: :desc).take.description).to eq 'Updated description'
      end
    end

    context 'Error' do
      context 'When request is unauthorized' do
        subject do
          post :create, params: { visit: visit_json }
        end

        it 'returns unauthorized message error' do
          subject
          expect(response.status).to eq(401)
        end
      end

      context 'When has already a visit at same time' do
        before do
          patient = create(:patient)
          visitor = create(:visitor)
          old_visit = create(:visit, patient_id: patient.id, visitor_id: visitor.id)
          create(:visit, patient_id: patient.id,
                         visitor_id: visitor.id,
                         start_date: old_visit.start_date + 41.minutes,
                         end_date: old_visit.end_date + 41.minutes)
          allow(JsonWebToken).to receive(:decode)
            .and_return({ visitor_id: visitor.id })
        end

        subject do
          current_visit = Visit.order(created_at: :desc).take
          new_attrs = { 'start_date' => (current_visit.start_date - 60.minutes).to_s,
                        'description' => 'Updated description' }
          post :update, params: { id: current_visit.id,
                                  visit: JSON.parse(current_visit.to_json).merge!(new_attrs) }
        end

        it 'returns conflict message error' do
          subject
          expect(response.status).to eq(409)
        end
      end
    end
  end
end
