module Api
  class PatientsController < ApplicationController

    def index
      render json: { status: 'OK' }
    end

    def create
      command = Core::Commands::CreatePatientCommand.new(patient_params: permitted_params.to_h)
      patient_id = Core::CommandHandlers::CreatePatientCommandHandler.new.create_patient(command)

      render json: { id: patient_id }
    end

    private

    def permitted_params
      params.require(:patient).permit!
    end

  end
end