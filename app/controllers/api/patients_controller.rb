# frozen_string_literal: true

module Api
  class PatientsController < ApplicationController
    def initialize(repositories = {})
      @list_patients_use_case = Arkham::Dependencies.list_patients_use_case
      @create_patient_use_case = Arkham::Dependencies.create_patient_use_case
      @update_patient_use_case = Arkham::Dependencies.update_patient_use_case
      @destroy_patient_use_case = Arkham::Dependencies.destroy_patient_use_case
      @activate_patient_use_case = Arkham::Dependencies.activate_patient_use_case
      @inactivate_patient_use_case = Arkham::Dependencies.inactivate_patient_use_case
    end

    def index
      filter_params = patient_find_params
      patients = @list_patients_use_case.execute(filter_params)

      render json: Arkham::Presenters::PatientListPresenter.new(patients).to_json
    end

    def create
      patient_params = permitted_params.to_h
      patient_id = @create_patient_use_case.execute(patient_params)

      render json: Arkham::Presenters::PatientCreatedPresenter.new(patient_id).to_json
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def update
      patient_params = permitted_params.to_h
      patient_id = @update_patient_use_case.execute(params[:id], patient_params)

      render json: Arkham::Presenters::PatientUpdatedPresenter.new(patient_id).to_json
    rescue Arkham::Domain::Errors::PatientNotFoundError
      head(:not_found)
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def destroy
      @destroy_patient_use_case.execute(params[:id])

      head(:ok)
    rescue Arkham::Domain::Errors::PatientNotFoundError
      head(:not_found)
    end

    def activate
      patient_id = @activate_patient_use_case.execute(params[:id])
      render json: Arkham::Presenters::PatientUpdatedPresenter.new(patient_id).to_json
    rescue Arkham::Domain::Errors::PatientNotFoundError
      head(:not_found)
    end

    def inactivate
      patient_id = @inactivate_patient_use_case.execute(params[:id])
      render json: Arkham::Presenters::PatientUpdatedPresenter.new(patient_id).to_json
    rescue Arkham::Domain::Errors::PatientNotFoundError
      head(:not_found)
    end

    private

    def patient_find_params
      params.except(:format, :action, :controller, :application).permit(:id, :status).to_h
    end

    def permitted_params
      params.require(:patient).permit!
    end
  end
end
