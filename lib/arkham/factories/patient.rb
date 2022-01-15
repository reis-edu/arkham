# frozen_string_literal: true

module Factories
  class Patient
    def initialize(attrs, repositories = {})
      @attrs = attrs
      @repositories = repositories
    end

    def result
      patient_validation = Schemas::Patient.new.call(@attrs)
      return patient_validation.to_h unless patient_validation.errors.any?

      raise Api::Errors::SchemaValidationError, patient_validation.errors
    end

    def patient_repository
      @repositories.fetch(:patient) do
        Infra::Repositories::PatientRepository.new
      end
    end

    def patient_photo_repository
      @repositories.fetch(:patient_photo) do
        Infra::Repositories::PatientPhotoRepository.new
      end
    end
  end
end
