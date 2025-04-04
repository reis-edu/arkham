module Arkham
  module UseCases
    class ShowPatient
      def initialize(patient_repository)
        @patient_repository = patient_repository
      end

      def execute(patient_id)
        find_patient(patient_id)
      end

      private

      def find_patient(patient_id)
        patient = @patient_repository.find_by_id(patient_id)

        unless patient
          raise Arkham::Domain::Errors::PatientNotFoundError, 'Patient not found'
        end

        patient
      end
    end
  end
end
