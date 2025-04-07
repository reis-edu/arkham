require 'aws-sdk-s3'

module Arkham
  module Repository
    module Filebase
      class PatientPhotoRepository
        def initialize(model = {})
          @patient_photo = model.fetch(:patient_photo) { PatientPhoto }
          @storage = Aws::S3::Client.new(
            region: Arkham.config[:filebase][:region],
            access_key_id: Arkham.config[:filebase][:access_key_id],
            secret_access_key: Arkham.config[:filebase][:secret_access_key],
            endpoint: Arkham.config[:filebase][:endpoint],
            force_path_style: Arkham.config[:filebase][:force_path_style]
          )
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

        def get_presigned_profile_url(patient_photo_key)
          Rails.cache.fetch("presigned_url:#{patient_photo_key}", expires_in: Arkham.config[:filebase][:presigned_url_expiration]) do
            Rails.logger.info("[S3 Presigned URL] Cache miss for key: #{patient_photo_key}. Generating new URL.")
            signer = Aws::S3::Presigner.new(client: @storage)

            signer.presigned_url(:get_object,
              bucket: Arkham.config[:filebase][:bucket],
              key: patient_photo_key,
              expires_in: Arkham.config[:filebase][:presigned_url_expiration]
            )
          end.tap do |url|
            Rails.logger.info("[S3 Presigned URL] Cache hit for key: #{patient_photo_key}. Returning cached URL.")
          end
        end
      end
    end
  end
end
