# frozen_string_literal: true

module Arkham
  module Presenters
    class PatientPresignedProfileUrlPresenter
      def initialize(presigned_url)
        @presigned_url = presigned_url
      end

      def to_json(*_args)
        {
          url: @presigned_url
        }
      end
    end
  end
end
