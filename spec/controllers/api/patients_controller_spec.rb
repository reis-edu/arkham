require 'rails_helper'
require 'google/cloud/storage'

RSpec.describe Api::PatientsController, type: :controller do
  let(:list_patients_use_case) { instance_double(Arkham::UseCases::ListPatients) }
  let(:create_patient_use_case) { instance_double(Arkham::UseCases::CreatePatient) }
  let(:update_patient_use_case) { instance_double(Arkham::UseCases::UpdatePatient) }
  let(:destroy_patient_use_case) { instance_double(Arkham::UseCases::DestroyPatient) }
  let(:activate_patient_use_case) { instance_double(Arkham::UseCases::ActivatePatient) }
  let(:inactivate_patient_use_case) { instance_double(Arkham::UseCases::InactivatePatient) }
  let(:show_patient_use_case) { instance_double('Arkham::UseCases::ShowPatient') }
  let(:patient) { double('Patient') }
  let(:patient_presenter) { double('Arkham::Presenters::PatientPresenter') }
  let(:patient_json) { { id: 1, name: 'John Doe' }.to_json }

  before(:each) do
    allow(Arkham::Dependencies).to receive(:list_patients_use_case).and_return(list_patients_use_case)
    allow(Arkham::Dependencies).to receive(:create_patient_use_case).and_return(create_patient_use_case)
    allow(Arkham::Dependencies).to receive(:update_patient_use_case).and_return(update_patient_use_case)
    allow(Arkham::Dependencies).to receive(:destroy_patient_use_case).and_return(destroy_patient_use_case)
    allow(Arkham::Dependencies).to receive(:activate_patient_use_case).and_return(activate_patient_use_case)
    allow(Arkham::Dependencies).to receive(:inactivate_patient_use_case).and_return(inactivate_patient_use_case)
    allow(Arkham::Dependencies).to receive(:show_patient_use_case).and_return(show_patient_use_case)
    allow(patient_presenter).to receive(:to_json).and_return(patient_json)
  end

  describe 'GET #index' do
    context 'when no filters are provided' do
      let!(:patient) { create(:patient) }

      it 'returns all patients' do
        get :index, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_present
        
        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
        expect(json_response['patients']).to be_present
        expect(json_response['patients']).to be_an(Array)
        expect(json_response['patients'].length).to eq(1)
        
        patient_response = json_response['patients'].first
        expect(patient_response).to include(
          'id',
          'firstname',
          'lastname',
          'cpf',
          'gender',
          'status',
          'birth_date',
          'photo_url',
          'age',
          'active'
        )
        
        expect(patient_response['id']).to eq(patient.id)
        expect(patient_response['firstname']).to eq(patient.firstname)
        expect(patient_response['lastname']).to eq(patient.lastname)
        expect(patient_response['cpf']).to eq(patient.cpf)
        expect(patient_response['gender']).to eq(patient.gender)
        expect(patient_response['status']).to eq(patient.status)
        expect(patient_response['birth_date']).to eq(patient.birth_date.as_json)
        expect(patient_response['photo_url']).to eq(patient.photo_url)
        expect(patient_response['age']).to eq(patient.age)
        expect(patient_response['active']).to eq(patient.active?)
      end
    end

    context 'when filters are provided' do
      let!(:active_patient) { create(:patient, status: 'active', cpf: '123.506.300-14') }
      let!(:inactive_patient) { create(:patient, status: 'inactive', cpf: '123.506.300-15') }

      it 'returns filtered patients' do
        get :index, params: { status: 'active' }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_present
        
        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
        expect(json_response['patients']).to be_present
        expect(json_response['patients']).to be_an(Array)
        expect(json_response['patients'].length).to eq(1)
        
        patient_response = json_response['patients'].first
        expect(patient_response['status']).to eq('active')
        expect(patient_response['id']).to eq(active_patient.id)
      end
    end
  end

  describe 'POST #create' do
    let(:patient_params) do
      {
        firstname: 'John',
        lastname: 'Doe',
        cpf: '123.456.789-14',
        gender: 'm',
        status: 'active',
        birth_date: '1990-01-01',
        diagnosis: 'Some diagnosis'
      }
    end

    context 'when patient is created successfully' do
      it 'returns created patient id' do
        post :create, params: { patient: patient_params }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_present

        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
        expect(json_response['id']).to be_present
        
        created_patient = Patient.find(json_response['id'])
        expect(created_patient.firstname).to eq(patient_params[:firstname])
        expect(created_patient.lastname).to eq(patient_params[:lastname])
        expect(created_patient.cpf).to eq(patient_params[:cpf])
        expect(created_patient.gender).to eq(patient_params[:gender])
        expect(created_patient.status).to eq(patient_params[:status])
        expect(created_patient.birth_date.to_date).to eq(Date.parse(patient_params[:birth_date]))
        expect(created_patient.diagnosis).to eq(patient_params[:diagnosis])
      end
    end

    context 'when patient params are invalid' do
      let(:invalid_params) do
        {
          firstname: '',
          lastname: '',
          cpf: '',
          gender: '',
          status: '',
          birth_date: '',
          diagnosis: ''
        }
      end

      it 'returns unprocessable entity status' do
        post :create, params: { patient: invalid_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_present
        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)

        expect(json_response['error']).to be_present
      end
    end

    context 'when patient already exists' do
      let!(:existing_patient) { create(:patient, cpf: patient_params[:cpf]) }

      it 'returns unprocessable entity status' do
        post :create, params: { patient: patient_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_present
        
        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'PUT #update' do
    let!(:patient) { create(:patient) }
    let(:patient_params) do
      {
        firstname: 'John',
        lastname: 'Doe',
        cpf: '123.456.789-10',
        gender: 'm',
        status: 'active',
        birth_date: '1990-01-01',
        diagnosis: 'Some diagnosis'
      }
    end

    context 'when patient is updated successfully' do
      it 'returns updated patient id' do
        put :update, params: { id: patient.id, patient: patient_params }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_present
        
        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
        expect(json_response['id']).to eq(patient.id)
        
        updated_patient = Patient.find(patient.id)
        expect(updated_patient.firstname).to eq(patient_params[:firstname])
        expect(updated_patient.lastname).to eq(patient_params[:lastname])
        expect(updated_patient.cpf).to eq(patient_params[:cpf])
        expect(updated_patient.gender).to eq(patient_params[:gender])
        expect(updated_patient.status).to eq(patient_params[:status])
        expect(updated_patient.birth_date.to_date).to eq(Date.parse(patient_params[:birth_date]))
        expect(updated_patient.diagnosis).to eq(patient_params[:diagnosis])
      end
    end

    context 'when patient is not found' do
      it 'returns not found status' do
        put :update, params: { id: SecureRandom.uuid, patient: patient_params }

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when patient params are invalid' do
      let(:invalid_params) do
        {
          firstname: '',
          lastname: '',
          cpf: '',
          gender: '',
          status: '',
          birth_date: '',
          diagnosis: ''
        }
      end

      it 'returns unprocessable entity status' do
        put :update, params: { id: patient.id, patient: invalid_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_present
        
        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:patient) { create(:patient) }

    context 'when patient is destroyed successfully' do
      it 'returns ok status' do
        expect {
          delete :destroy, params: { id: patient.id }
        }.to change(Patient, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when patient is not found' do
      it 'returns not found status' do
        delete :destroy, params: { id: SecureRandom.uuid }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT #activate' do
    let!(:patient) { create(:patient, status: 'inactive') }

    context 'when patient is activated successfully' do
      it 'returns activated patient id' do
        put :activate, params: { id: patient.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_present
        
        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
        expect(json_response['id']).to eq(patient.id)
        
        activated_patient = Patient.find(patient.id)
        expect(activated_patient.status).to eq('active')
      end
    end

    context 'when patient is not found' do
      it 'returns not found status' do
        put :activate, params: { id: SecureRandom.uuid }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT #inactivate' do
    let!(:patient) { create(:patient, status: 'active') }

    context 'when patient is inactivated successfully' do
      it 'returns inactivated patient id' do
        put :inactivate, params: { id: patient.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_present
        
        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
        expect(json_response['id']).to eq(patient.id)
        
        inactivated_patient = Patient.find(patient.id)
        expect(inactivated_patient.status).to eq('inactive')
      end
    end

    context 'when patient is not found' do
      it 'returns not found status' do
        put :inactivate, params: { id: SecureRandom.uuid }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET #show' do
    let!(:patient) { create(:patient) }

    context 'when patient exists' do
      it 'returns the patient as JSON' do
        get :show, params: { id: patient.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(patient.id)
      end
    end

    context 'when patient does not exist' do
      it 'returns not found status' do
        get :show, params: { id: '123' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
