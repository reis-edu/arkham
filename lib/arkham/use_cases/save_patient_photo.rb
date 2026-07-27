module Arkham
  module UseCases
    class SavePatientPhoto
      def initialize(patient_repository, patient_photo_repository)
        @patient_repository = patient_repository
        @patient_photo_repository = patient_photo_repository
      end

      def execute(patient_id, photo_params)
        patient_photo = @patient_photo_repository.save(
          patient_id,
          photo_params[:photo_base64],
          photo_params[:photo_base64_format]
        )

        @patient_repository.update(
          patient_id,
          {
            photo_url: patient_photo.photo_url,
            photo_key: patient_photo.photo_key
          }
        )
      end
    end
  end
end
