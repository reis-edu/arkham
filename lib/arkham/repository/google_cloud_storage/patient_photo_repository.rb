require 'google/cloud/storage'

module Arkham
  module Repository
    module GoogleCloudStorage
      class PatientPhotoRepository
        def initialize(model = {})
          @patient_photo = model.fetch(:patient_photo) { ::PatientPhoto }
        end

        def load(patient_id, photo_base64, photo_base64_format)
          @patient_photo.new(
            patient_id,
            photo_base64,
            photo_base64_format
          )
        end

        def save(patient_photo)
          patient_photo.save
        end

        def valid?(patient_photo)
          return false if patient_photo.base64_image.nil? || patient_photo.base64_image.empty?
          return false if patient_photo.patient_id.nil? || patient_photo.patient_id.empty?

          true
        end
      end
    end
  end
end
