# frozen_string_literal: true

module Core
  module Commands
    class CreatePatientCommand
      attr_accessor :patient, :patient_photo

      def initialize(patient_params:)
        @patient = define_patient(patient_params)
        @patient_photo = define_patient_photo(patient_params['photo'])
      end

      private

      def define_patient(patient_params)
        patient_validation = Api::PatientSchema.call(patient_params)
        return patient_validation.output unless patient_validation.errors.any?

        raise Api::Errors::SchemaValidationError, patient_validation.errors
      end

      def define_patient_photo(photo_params)
        return {} if photo_params.nil? || photo_params.empty?

        patient_photo_validation = Api::PatientPhotoSchema.call(photo_params)
        return patient_photo_validation.output unless patient_photo_validation.errors.any?

        raise Api::Errors::SchemaValidationError, patient_photo_validation.errors
      end
    end
  end
end
