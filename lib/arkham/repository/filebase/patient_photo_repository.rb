# frozen_string_literal: true

require 'aws-sdk-s3'

module Arkham
  module Repository
    module Filebase
      class PatientPhotoRepository
        def initialize(_model = {})
          @s3_client = s3_client
          @s3_resource = s3_resource
        end

        # rubocop:disable Metrics/MethodLength
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
          raise Domain::Errors::PatientPhotoError, "Error on save patient photo! Error: #{e}"
        end
        # rubocop:enable Metrics/MethodLength

        def delete(photo_key)
          return unless photo_key.present?

          @s3_resource.bucket(Arkham.config[:filebase][:bucket]).object(photo_key).delete
        rescue StandardError => e
          raise Domain::Errors::PatientPhotoError, "Error on delete patient photo! Error: #{e}"
        end

        # rubocop:disable Style/MultilineBlockChain
        def get_presigned_profile_url(patient_photo_key)
          Rails.cache.fetch("presigned_url:#{patient_photo_key}",
                            expires_in: Arkham.config[:filebase][:presigned_url_expiration]) do
            Rails.logger.info("[S3 Presigned URL] Cache miss for key: #{patient_photo_key}. Generating new URL.")
            signer = Aws::S3::Presigner.new(client: @s3_client)

            signer.presigned_url(:get_object,
                                 bucket: Arkham.config[:filebase][:bucket],
                                 key: patient_photo_key,
                                 expires_in: Arkham.config[:filebase][:presigned_url_expiration])
          end.tap do |_url|
            Rails.logger.info("[S3 Presigned URL] Cache hit for key: #{patient_photo_key}. Returning cached URL.")
          end
        end
        # rubocop:enable Style/MultilineBlockChain

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
