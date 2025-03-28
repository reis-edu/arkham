module Arkham
  module Core
    module UseCases
      class ListPatients
        def initialize(patient_repository)
          @patient_repository = patient_repository
        end
        
        def execute(filter_params = {})
          @patient_repository.find_all(filter_params)
        end
      end
    end
  end
end
