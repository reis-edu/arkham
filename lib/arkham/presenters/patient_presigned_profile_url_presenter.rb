module Arkham
  module Presenters
    class PatientPresignedProfileUrlPresenter
      def initialize(presigned_url)
        @presigned_url = presigned_url
      end

      def to_json
        {
          url: @presigned_url
        }
      end
    end
  end
end
