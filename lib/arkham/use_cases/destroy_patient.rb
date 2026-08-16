# frozen_string_literal: true

module Arkham
  module UseCases
    class DestroyPatient
      def initialize(patient_repository)
        @patient_repository = patient_repository
      end

      def execute(patient_id)
        find_patient(patient_id)

        @patient_repository.within_transaction do
          @patient_repository.destroy(patient_id)
        end
      end

      private

      def find_patient(patient_id)
        patient = @patient_repository.find_by_id(patient_id)

        raise Arkham::Domain::Errors::PatientNotFoundError, 'Patient not found' unless patient

        patient
      end
    end
  end
end
