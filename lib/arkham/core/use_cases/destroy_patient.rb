module Arkham
  module Core
    module UseCases
      class DestroyPatient
        def initialize(patient_repository)
          @patient_repository = patient_repository
        end
        
        def execute(patient_id)
          patient = find_patient(patient_id)

          ActiveRecord::Base.transaction do
            @patient_repository.destroy(patient_id)
          end
        end
        
        private
        
        def find_patient(patient_id)
          patient = @patient_repository.find_by_id(patient_id)

          unless patient
            raise Arkham::Domain::Errors::PatientNotFoundError
          end

          patient
        end
      end
    end
  end
end
