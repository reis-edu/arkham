# frozen_string_literal: true

module Api
  class PatientsController < ApplicationController
    def initialize(repositories = {})
      @patient_repository = repositories.fetch(:patient) do
        Infra::Repositories::PatientRepository.new
      end
    end

    def index
      @patients = list_patients
    end

    def create
      patient_id = Services::Patients::Create.new(permitted_params.to_h).execute

      render json: { id: patient_id }
    end

    def update
      patient_id = Services::Patients::Update.new(params[:id], permitted_params.to_h).execute

      render json: { id: patient_id }
    rescue ActiveRecord::RecordNotFound
      head(:not_found)
    end

    def destroy
      Services::Patients::Destroy.new(params[:id]).execute

      head(:ok)
    rescue ActiveRecord::RecordNotFound
      head(:not_found)
    end

    def activate
      patient = @patient_repository.find_by_id(params[:id])
      return head(:not_found) unless patient

      @patient_repository.activate!(patient)

      render json: { id: patient.id }
    end

    def inactivate
      patient = @patient_repository.find_by_id(params[:id])
      return head(:not_found) unless patient

      @patient_repository.inactivate!(patient)

      render json: { id: patient.id }
    end

    private

    def list_patients
      Services::Patients::Finder.find_patients(patient_find_params)
    end

    def patient_find_params
      params.except(:format).permit(:id, :status)
    end

    def permitted_params
      params.require(:patient).permit!
    end
  end
end
