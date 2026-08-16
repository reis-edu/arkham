# frozen_string_literal: true

require 'aws-sdk-s3'

module Arkham
  module Repository
    module Filebase
      class PatientPhoto
        attr_reader :patient_id, :base64_image, :base64_image_format, :photo_url, :photo_key

        def initialize(storage, patient_id, base64_image, base64_image_format = 'png', _s3_resource = nil)
          @base64_image = base64_image
          @patient_id = patient_id
          @base64_image_format = base64_image_format
          @storage = storage
          @bucket = @storage.bucket Arkham.config[:filebase][:bucket]
        end

        def save
          filebase_image = @bucket.object(file_path)
          filebase_image.put(body: StringIO.new(serialized_image), acl: file_acl)

          @photo_key = file_path
          @photo_url = filebase_image.public_url
        end

        def valid?
          return false if base64_image.nil? || base64_image.empty?
          return false if patient_id.nil? || patient_id.empty?

          true
        end

        private

        def file_path
          "#{Arkham.config[:filebase][:patient_path]}/profile-photo-#{patient_id}.#{base64_image_format}"
        end

        def file_acl
          Arkham.config[:filebase][:acl]
        end

        def serialized_image
          Base64.decode64(base64_image.split(',', 2).last)
        end
      end
    end
  end
end
