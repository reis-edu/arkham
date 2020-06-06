module Core
  module Commands
    class CreatePatientCommand
      attr_accessor :patient

      def initialize(patient_params:)
        set_patient(patient_params)
      end

      private
 
      def set_patient(patient_params)
        patient_validation = Api::PatientSchema.call(patient_params)
        raise Api::Errors::SchemaValidationError, patient_validation.errors if patient_validation.errors.any?

        @patient = patient_validation.output
      end
    end
  end
end