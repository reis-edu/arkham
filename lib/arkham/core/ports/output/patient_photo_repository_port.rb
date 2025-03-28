module Arkham
  module Core
    module Ports
      module Output
        module PatientPhotoRepositoryPort
          def save(patient_photo)
            raise NotImplementedError
          end
          
          def valid?(patient_photo)
            raise NotImplementedError
          end
        end
      end
    end
  end
end 