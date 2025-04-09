require 'aws-sdk-s3'

module Arkham
  module Repository
    module Filebase
      class PatientPhotoRepository
        attr_reader :s3_client, :s3_resource
        
        def initialize(model = {})
          @s3_client = s3_client
          @s3_resource = s3_resource
        end

        def save(patient_id, photo_base64, photo_base64_format)
          patient_photo = PatientPhoto.new(
            @s3_resource,
            patient_id,
            photo_base64,
            photo_base64_format
          )

          if patient_photo.valid?
            patient_photo.save
          else
            Arkham.logger.info(
              "Photo params is not valid: \npatient_id => #{patient_id}\n patient_photo => #{patient_photo}"
            )
          end

          patient_photo
        rescue StandardError => e
          raise Domain::Errors::PatientPhotoError.new("Error on save patient photo! Error: #{e}")
        end

        def get_presigned_profile_url(patient_photo_key)
          Rails.cache.fetch("presigned_url:#{patient_photo_key}", expires_in: Arkham.config[:filebase][:presigned_url_expiration]) do
            Rails.logger.info("[S3 Presigned URL] Cache miss for key: #{patient_photo_key}. Generating new URL.")
            signer = Aws::S3::Presigner.new(client: @s3_client)

            signer.presigned_url(:get_object,
              bucket: Arkham.config[:filebase][:bucket],
              key: patient_photo_key,
              expires_in: Arkham.config[:filebase][:presigned_url_expiration]
            )
          end.tap do |url|
            Rails.logger.info("[S3 Presigned URL] Cache hit for key: #{patient_photo_key}. Returning cached URL.")
          end
        end

        private

        def s3_client
          Aws::S3::Client.new(
            region: Arkham.config[:filebase][:region],
            access_key_id: Arkham.config[:filebase][:access_key_id],
            secret_access_key: Arkham.config[:filebase][:secret_access_key],
            endpoint: Arkham.config[:filebase][:endpoint],
            force_path_style: Arkham.config[:filebase][:force_path_style]
          )
        end

        def s3_resource
          Aws::S3::Resource.new(
            region: Arkham.config[:filebase][:region],
            access_key_id: Arkham.config[:filebase][:access_key_id],
            secret_access_key: Arkham.config[:filebase][:secret_access_key],
            endpoint: Arkham.config[:filebase][:endpoint],
            force_path_style: Arkham.config[:filebase][:force_path_style]
          )
        end
      end
    end
  end
end
