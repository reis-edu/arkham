module Arkham
  module AppCore
    module UseCases
      class ActivatePatient
        def initialize(patient_repository)
          @patient_repository = patient_repository
        end

        def execute(patient_id)

          patient = find_patient(patient_id)

          @patient_repository.activate(patient_id)

          patient_id
        end

        private

        def find_patient(patient_id)
          patient = @patient_repository.find_by_id(patient_id)

          unless patient
            raise ActiveRecord::RecordNotFound
          end

          patient
        end
      end
    end
  end
end
