module Api
  class PatientsController < ApplicationController

    def index
      render json: { status: 'OK' }
    end

    def create
      if patient_params.success?
        render json: patient_params
      else
        render json: { detail: patient_params.errors }, status: :precondition_failed
      end
    end

    private

    def patient_params
      @patient_params ||= Api::PatientSchema.call(params)
    end

  end
end