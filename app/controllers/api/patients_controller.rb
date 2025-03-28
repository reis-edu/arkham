# frozen_string_literal: true

module Api
  class PatientsController < ApplicationController
    def initialize(repositories = {})
      @list_patients_use_case = Arkham::Infrastructure::Dependencies.list_patients_use_case
      @create_patient_use_case = Arkham::Infrastructure::Dependencies.create_patient_use_case
      @update_patient_use_case = Arkham::Infrastructure::Dependencies.update_patient_use_case
      @destroy_patient_use_case = Arkham::Infrastructure::Dependencies.destroy_patient_use_case
      @activate_patient_use_case = Arkham::Infrastructure::Dependencies.activate_patient_use_case
      @inactivate_patient_use_case = Arkham::Infrastructure::Dependencies.inactivate_patient_use_case
    end

    def index
      filter_params = patient_find_params
      patients = @list_patients_use_case.execute(filter_params)

      render json: Arkham::Infrastructure::Adapters::Api::PatientPresenter.list(patients)
    end

    def create
      patient_params = permitted_params.to_h
      patient_id = @create_patient_use_case.execute(patient_params)

      render json: Arkham::Infrastructure::Adapters::Api::PatientPresenter.created(patient_id)
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def update
      patient_params = permitted_params.to_h
      patient_id = @update_patient_use_case.execute(params[:id], patient_params)

      render json: Arkham::Infrastructure::Adapters::Api::PatientPresenter.updated(patient_id)
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
      render json: Arkham::Infrastructure::Adapters::Api::PatientPresenter.activated(patient_id)
    rescue Arkham::Domain::Errors::PatientNotFoundError
      head(:not_found)
    end

    def inactivate
      patient_id = @inactivate_patient_use_case.execute(params[:id])
      render json: Arkham::Infrastructure::Adapters::Api::PatientPresenter.inactivated(patient_id)
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
