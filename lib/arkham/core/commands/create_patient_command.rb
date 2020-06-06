# frozen_string_literal: true

module Core
  module Commands
    class CreatePatientCommand
      attr_accessor :patient

      def initialize(patient_params:)
        @patient = define_patient(patient_params)
      end

      private

      def define_patient(patient_params)
        patient_validation = Api::PatientSchema.call(patient_params)
        return patient_validation.output unless patient_validation.errors.any?

        raise Api::Errors::SchemaValidationError, patient_validation.errors
      end
    end
  end
end
