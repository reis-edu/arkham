# frozen_string_literal: true

module Services
  module Patients
    class Create < Factories::Patient
      def initialize(attrs, repositories = {})
        super
      end

      def create
        new_patient = Patient.new(result.except(:photo))
        raise_patient_existent_error if Patient.exists?(cpf: new_patient.cpf)

        ActiveRecord::Base.transaction do
          patient_repository.save(new_patient)
          patient_photo = PatientPhoto.new(new_patient.id, result.dig(:photo, :photo_base64),
                                           result.dig(:photo, :photo_base64_format))
          if patient_photo_repository.valid?(patient_photo)
            save_patient_photo(patient_photo, new_patient)
          else
            log_photo_error(new_patient.id, result[:photo])
          end

          new_patient.id
        end
      end

      private

      def save_patient_photo(patient_photo, patient)
        patient_photo_repository.save(patient_photo)
        patient_repository.update(
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

      def raise_patient_existent_error
        raise Errors::Patient::PatientAlreadyExistsError, 'Patient with this CPF already exists!'
      end
    end
  end
end
