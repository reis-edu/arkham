# frozen_string_literal: true

module Core
  module CommandHandlers
    class CreatePatientCommandHandler
      def initialize(repositories = {})
        @patient_repository = repositories.fetch(:patient) { Infra::Repositories::PatientRepository.new }
        @patient_photo_repository = repositories.fetch(:patient_photo) do
          Infra::Repositories::PatientPhotoRepository.new
        end
      end

      def create_patient(create_patient_command)
        patient = Patient.new(create_patient_command.patient)
        raise_patient_existent_error if Patient.exists?(cpf: patient.cpf)

        ActiveRecord::Base.transaction do
          @patient_repository.save(patient)
          patient_photo = PatientPhoto.new(patient.id, create_patient_command.patient_photo[:photo_base64],
                                           create_patient_command.patient_photo[:photo_base64_format])
          if patient_photo.valid?
            save_patient_photo(patient_photo, patient)
          else
            log_photo_error(patient.id, create_patient_command.patient_photo)
          end

          patient.id
        end
      end

      private

      def save_patient_photo(patient_photo, patient)
        @patient_photo_repository.save(patient_photo)
        patient.photo_url = patient_photo.photo_url
        patient.photo_key = patient_photo.photo_key
        @patient_repository.save(patient)
      rescue StandardError => e
        raise Errors::Patient::PatientPhotoError, "Error on save patient photo! Error: #{e}"
      end

      def log_photo_error(patient_id, patient_photo)
        Arkham.logger.info(
          "Photo params is not valid: \npatient_id => #{patient_id}\n patient_photo => #{patient_photo}"
        )
      end

      def raise_patient_existent_error
        raise Errors::Patient::PatientAlreadyExistsError, 'Patient with this CPF already exists!'
      end
    end
  end
end
