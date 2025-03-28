module Arkham
  module AppCore
    module Ports
      module Output
        module PatientRepositoryPort
          def find_all(filter_params = {})
            raise NotImplementedError
          end
          
          def find_by_id(patient_id)
            raise NotImplementedError
          end
          
          def create(patient_params)
            raise NotImplementedError
          end
          
          def update(patient_id, update_params)
            raise NotImplementedError
          end
          
          def destroy(patient_id)
            raise NotImplementedError
          end
          
          def activate(patient_id)
            raise NotImplementedError
          end
          
          def inactivate(patient_id)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
