# frozen_string_literal: true

module Core
  module CommandHandlers
    class UpdatePatientCommandHandler
      def initialize(repositories = {})
        @patient_repository = repositories.fetch(:patient) { Infra::Repositories::PatientRepository.new }
        @patient_photo_repository = repositories.fetch(:patient_photo) do
          Infra::Repositories::PatientPhotoRepository.new
        end
      end

      def execute(command)
        patient = @patient_repository.find_by_id(command.id)
        raise ActiveRecord::RecordNotFound unless patient

        ActiveRecord::Base.transaction do
          @patient_repository.update(patient, command.patient)
          patient_photo = PatientPhoto.new(patient.id, command.patient_photo[:photo_base64],
                                           command.patient_photo[:photo_base64_format])
          if @patient_photo_repository.valid?(patient_photo)
            save_patient_photo(patient_photo, patient)
          else
            log_photo_error(patient.id, command.patient_photo)
          end

          patient.id
        end
      end

      private

      def save_patient_photo(patient_photo, patient)
        @patient_photo_repository.save(patient_photo)
        @patient_repository.update(
          patient,
          {
            photo_url: patient_photo.photo_url,
            photo_key: patient_photo.photo_key
          }
        )
      rescue StandardError => e
        raise Errors::Patient::PatientPhotoError, "Error on save patient photo! Error: #{e}"
      end

      def log_photo_error(patient_id, patient_photo)
        Arkham.logger.info(
          "Photo params is not valid: \npatient_id => #{patient_id}\n patient_photo => #{patient_photo}"
        )
      end
    end
  end
end
