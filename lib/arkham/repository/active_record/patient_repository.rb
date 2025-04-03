module Arkham
  module Repository
    module ActiveRecord
      class PatientRepository
        def find_all(filter_params = {})
          patients = ::Patient.where(filter_params).all
          patients.map { |patient| map_to_entity(patient) }
        end
        
        def find_by_id(patient_id)
          patient = ::Patient.find_by(id: patient_id)
          return nil unless patient
          
          map_to_entity(patient)
        end

        def create(patient_params)
          patient = ::Patient.create!(patient_params)
          patient.id
        end

        def update(patient_id, update_params)
          patient = ::Patient.find(patient_id)
          patient.update!(update_params)
          patient.id
        end

        def destroy(patient_id)
          patient = ::Patient.find(patient_id)
          patient.destroy
        end

        def activate(patient_id)
          patient = ::Patient.find(patient_id)
          patient.update!(status: 'active')
          patient.id
        end

        def inactivate(patient_id)
          patient = ::Patient.find(patient_id)
          patient.update!(status: 'inactive')
          patient.id
        end

        private

        def map_to_entity(record)
          Arkham::Domain::Entities::Patient.new(
            id: record.id,
            firstname: record.firstname,
            lastname: record.lastname,
            cpf: record.cpf,
            gender: record.gender,
            status: record.status,
            birth_date: record.birth_date,
            photo_url: record.photo_url,
            photo_key: record.photo_key
          )
        end
      end
    end
  end
end
