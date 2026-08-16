# frozen_string_literal: true

module Arkham
  module UseCases
    class ActivatePatient
      def initialize(patient_repository)
        @patient_repository = patient_repository
      end

      def execute(patient_id)
        find_patient(patient_id)

        @patient_repository.activate(patient_id)

        patient_id
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
