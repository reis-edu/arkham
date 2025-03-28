module Arkham
  module AppCore
    module UseCases
      class CreatePatient
        def initialize(patient_repository, patient_photo_repository)
          @patient_repository = patient_repository
          @patient_photo_repository = patient_photo_repository
        end
        
        def execute(patient_params)
          validated_params = validate_patient_params(patient_params)
          check_patient_exists(validated_params[:cpf])

          ActiveRecord::Base.transaction do
            photo_params = validated_params.delete(:photo)
            patient_id = @patient_repository.create(validated_params)

            if photo_params.present? && photo_params[:photo_base64].present?
              process_patient_photo(patient_id, photo_params)
            end

            patient_id
          end
        end
        
        private
        
        def validate_patient_params(params)
          patient_validation = Schemas::Patient.new.call(params)

          if patient_validation.errors.any?
            raise Api::Errors::SchemaValidationError, patient_validation.errors
          end

          patient_validation.to_h
        end
        
        def check_patient_exists(cpf)
          if ::Patient.exists?(cpf: cpf)
            raise Errors::Patient::PatientAlreadyExistsError, 'Patient with this CPF already exists!'
          end
        end

        def process_patient_photo(patient_id, photo_params)
          patient_photo = PatientPhoto.new(
            patient_id, 
            photo_params[:photo_base64],
            photo_params[:photo_base64_format]
          )

          if @patient_photo_repository.valid?(patient_photo)
            save_patient_photo(patient_photo, patient_id)
          else
            log_photo_error(patient_id, photo_params)
          end
        end
        
        def save_patient_photo(patient_photo, patient_id)
          @patient_photo_repository.save(patient_photo)

          @patient_repository.update(
            patient_id,
            {
              photo_url: patient_photo.photo_url,
              photo_key: patient_photo.photo_key
            }
          )
        rescue StandardError => e
          raise Errors::Patient::PatientPhotoError, "Error on save patient photo! Error: #{e}"
        end

        def log_photo_error(patient_id, patient_photo)
          Arkham.logger.info(
            "Photo params is not valid: \npatient_id => #{patient_id}\n patient_photo => #{patient_photo}"
          )
        end
      end
    end
  end
end
