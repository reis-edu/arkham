# frozen_string_literal: true

module Infra
  module Repositories
    class PatientPhotoRepository
      def initialize(model = {})
        @patient_photo = model.fetch(:patient_photo) { PatientPhoto }
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
