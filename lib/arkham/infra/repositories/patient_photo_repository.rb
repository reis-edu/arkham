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
    end
  end
end
