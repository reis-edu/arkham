# frozen_string_literal: true

module Api
  class PatientsController < ApplicationController
    def index
      @patients = list_patients
    end

    def create
      command = Core::Commands::CreatePatientCommand.new(patient_params: permitted_params.to_h)
      patient_id = Core::CommandHandlers::CreatePatientCommandHandler.new.create_patient(command)

      render json: { id: patient_id }
    end

    private

    def list_patients
      Api::Patient::FinderService.find_patients(patient_find_params)
    end

    def patient_find_params
      params.permit(:id, :status)
    end

    def permitted_params
      params.require(:patient).permit!
    end
  end
end
