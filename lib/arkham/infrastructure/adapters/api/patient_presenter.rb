module Arkham
  module Infrastructure
    module Adapters
      module Api
        class PatientPresenter
          def self.list(patients)
            {
              patients: patients.map { |patient| format_patient(patient) }
            }
          end

          def self.to_json(patient)
            {
              patient: format_patient(patient)
            }
          end

          def self.created(patient_id)
            {
              id: patient_id
            }
          end

          def self.updated(patient_id)
            {
              id: patient_id
            }
          end

          def self.activated(patient_id)
            {
              id: patient_id
            }
          end

          def self.inactivated(patient_id)
            {
              id: patient_id
            }
          end

          private

          def self.format_patient(patient)
            {
              id: patient.id,
              firstname: patient.firstname,
              lastname: patient.lastname,
              fullname: patient.fullname,
              cpf: patient.cpf,
              gender: patient.gender,
              status: patient.status,
              birth_date: patient.birth_date,
              photo_url: patient.photo_url,
              age: patient.age,
              active: patient.active?
            }
          end
        end
      end
    end
  end
end
