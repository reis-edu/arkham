module Arkham
  module UseCases
    class GetPresignedProfileUrl
      def initialize(patient_photo_repository)
        @patient_photo_repository = patient_photo_repository
      end

      def execute(patient_photo_key)
        @patient_photo_repository.get_presigned_profile_url(patient_photo_key)
      end
    end
  end
end
