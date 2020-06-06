module Api
  class PatientsController < ApplicationController

    def index
      render json: { status: 'OK' }
    end

    def create
      if patient_params.success?
        command = Core::Commands::CreatePatientCommand.new(patient: @patient_params.output)
        patient_id = Core::CommandHandlers::CreatePatientCommandHandler.new.create_patient(command)

        render json: { id: patient_id }
      else
        render json: { detail: @patient_params.errors }, status: :precondition_failed
      end
    end

    private

    def patient_params
      @patient_params ||= Api::PatientSchema.call(permitted_params.to_h)
    end

    def permitted_params
      params.require(:patient).permit!
    end

  end
end