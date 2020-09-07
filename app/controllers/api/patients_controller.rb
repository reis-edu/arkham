# frozen_string_literal: true

module Api
  class PatientsController < ApplicationController
    def initialize(repositories = {})
      @patient_repository = repositories.fetch(:patient) { Infra::Repositories::PatientRepository.new }
    end

    def index
      @patients = list_patients
    end

    def create
      command = Core::Commands::CreatePatientCommand.new(patient_params: permitted_params.to_h)
      patient_id = Core::CommandHandlers::CreatePatientCommandHandler.new.execute(command)

      render json: { id: patient_id }
    end

    def update
      command = Core::Commands::UpdatePatientCommand.new(id: params[:id], patient_params: permitted_params.to_h)
      patient_id = Core::CommandHandlers::UpdatePatientCommandHandler.new.execute(command)

      render json: { id: patient_id }
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
      Api::Patient::FinderService.find_patients(patient_find_params)
    end

    def patient_find_params
      params.except(:format).permit(:id, :status)
    end

    def permitted_params
      params.require(:patient).permit!
    end
  end
end
