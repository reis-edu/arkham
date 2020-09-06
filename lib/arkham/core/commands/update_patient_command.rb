# frozen_string_literal: true

module Core
  module Commands
    class UpdatePatientCommand
      attr_accessor :id, :patient, :patient_photo

      def initialize(id:, patient_params:)
        @id = id
        @patient = define_patient(patient_params)
        @patient_photo = define_patient_photo(patient_params['photo'])
      end

      def define_patient(patient_params)
        patient_params.except(:photo)
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
