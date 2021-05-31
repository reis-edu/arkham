# frozen_string_literal: true

module Api
  class VitalSignsController < ApplicationController
    def create
      command = Core::Commands::CreateVitalSignCommand.new(creation_permitted_params.to_h)
      vital_sign_id = Core::CommandHandlers::CreateVitalSignCommandHandler.new.execute(command)

      render json: { id: vital_sign_id }
    end

    private

    def creation_permitted_params
      params.permit(:patient_id, :date, :period,
                    :pa, :bpm, :saturation, :blood_glucose,
                    :temperature, :diuresis, :feces).to_h
    end
  end
end
