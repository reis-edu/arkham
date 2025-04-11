module Arkham
  module Repository
    module ActiveRecord
      class PatientRepository
        def within_transaction(&block)
          ::ActiveRecord::Base.transaction do
            yield if block_given?
          end
        end

        def find_all(filter_params = {})
          patients = PatientFilterRepository.new.call(filter_params)
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

        def find_by_cpf(cpf)
          patient = ::Patient.find_by(cpf: cpf)
          return nil unless patient
          
          map_to_entity(patient)
        end

        private

        def map_to_entity(patient)
          Arkham::Domain::Entities::Patient.new(
            id: patient.id,
            firstname: patient.firstname,
            lastname: patient.lastname,
            cpf: patient.cpf,
            gender: patient.gender,
            status: patient.status,
            birth_date: patient.birth_date,
            photo_url: patient.photo_url,
            photo_key: patient.photo_key
          )
        end
      end
    end
  end
end
