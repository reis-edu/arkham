# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from Api::Errors::SchemaValidationError do |validation_error|
    render_unprocessable_entity(validation_error.errors)
  end

  rescue_from Core::Errors::Patient::PatientAlreadyExistsError do |error|
    render_unprocessable_entity(error.message)
  end

  private

  def render_unprocessable_entity(error_message)
    render json: { detail: error_message }, status: :unprocessable_entity
  end
end
