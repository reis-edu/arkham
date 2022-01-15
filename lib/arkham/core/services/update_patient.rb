module Core
  module Services
    class UpdatePatient < Factories::Patient

      def initialize(id, attrs, repositories = {})
        super(attrs, repositories)
        @id = id
      end

      def update
        patient = patient_repository.find_by_id(@id)
        raise ActiveRecord::RecordNotFound unless patient

        ActiveRecord::Base.transaction do
          patient_repository.update(patient, result.except(:photo))
          patient_photo = PatientPhoto.new(patient.id, result.dig(:photo, :photo_base64),
                                            result.dig(:photo, :photo_base64_format))
          if patient_photo_repository.valid?(patient_photo)
            save_patient_photo(patient_photo, patient)
          else
            log_photo_error(patient.id, result[:photo])
          end

          patient.id
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
    end
  end
end
