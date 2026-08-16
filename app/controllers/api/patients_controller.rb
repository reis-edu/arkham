# frozen_string_literal: true

module Api
  class PatientsController < ApplicationController
    def initialize(_repositories = {})
      @show_patient_use_case = Arkham::Dependencies.show_patient_use_case
      @list_patients_use_case = Arkham::Dependencies.list_patients_use_case
      @create_patient_use_case = Arkham::Dependencies.create_patient_use_case
      @update_patient_use_case = Arkham::Dependencies.update_patient_use_case
      @destroy_patient_use_case = Arkham::Dependencies.destroy_patient_use_case
      @activate_patient_use_case = Arkham::Dependencies.activate_patient_use_case
      @inactivate_patient_use_case = Arkham::Dependencies.inactivate_patient_use_case
      @get_presigned_profile_url_use_case = Arkham::Dependencies.get_presigned_profile_url_use_case
    end

    def index
      filter_params = patient_find_params
      patients = @list_patients_use_case.execute(filter_params)

      render json: Arkham::Presenters::PatientListPresenter.new(patients).to_json
    end

    def show
      patient = @show_patient_use_case.execute(params[:id])
      render json: Arkham::Presenters::PatientPresenter.new(patient).to_json
    end

    def presigned_profile_url
      presigned_url = @get_presigned_profile_url_use_case.execute(params[:profile_url_key])
      render json: Arkham::Presenters::PatientPresignedProfileUrlPresenter.new(presigned_url).to_json
    end

    def create
      patient_params = permitted_params.to_h
      patient_id = @create_patient_use_case.execute(patient_params)

      render json: Arkham::Presenters::PatientCreatedPresenter.new(patient_id).to_json
    end

    def update
      patient_params = permitted_params.to_h
      patient_id = @update_patient_use_case.execute(params[:id], patient_params)

      render json: Arkham::Presenters::PatientUpdatedPresenter.new(patient_id).to_json
    end

    def destroy
      @destroy_patient_use_case.execute(params[:id])

      head(:ok)
    end

    def activate
      patient_id = @activate_patient_use_case.execute(params[:id])
      render json: Arkham::Presenters::PatientUpdatedPresenter.new(patient_id).to_json
    end

    def inactivate
      patient_id = @inactivate_patient_use_case.execute(params[:id])
      render json: Arkham::Presenters::PatientUpdatedPresenter.new(patient_id).to_json
    end

    private

    def patient_find_params
      params.except(:format, :action, :controller, :application).permit(:status, :search_term).to_h
    end

    def permitted_params
      params.require(:patient).permit!
    end
  end
end
