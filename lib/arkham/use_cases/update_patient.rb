module Arkham
  module UseCases
    class UpdatePatient
      def initialize(patient_repository, patient_photo_repository)
        @patient_repository = patient_repository
        @patient_photo_repository = patient_photo_repository
      end

      def execute(patient_id, patient_params)
        validated_params = validate_patient_params(patient_params)
        patient = find_patient(patient_id)

        @patient_repository.within_transaction do
          check_duplicate_cpf(patient_id, validated_params[:cpf]) if validated_params[:cpf].present?
          photo_params = validated_params.delete(:photo)
          @patient_repository.update(patient_id, validated_params)

          if photo_params.present? && photo_params[:photo_base64].present?
            process_patient_photo(patient_id, photo_params)
          end

          patient_id
        end
      end

      private

      def check_duplicate_cpf(patient_id, new_cpf)
        existing_patient = @patient_repository.find_by_cpf(new_cpf)
        if existing_patient && existing_patient.id != patient_id
          raise Domain::Errors::PatientAlreadyExistsError, 'Patient with this CPF already exists!'
        end
      end

      def validate_patient_params(args)
        patient_params = Validators::Api::PatientContract.new.call(args)
        if patient_params.errors.any?
          raise Validators::Errors::ApiValidationError.new(patient_params.errors.to_h), 'Patient params are not valid!'
        end

        patient_params.to_h
      end

      def find_patient(patient_id)
        patient = @patient_repository.find_by_id(patient_id)

        unless patient
          raise Domain::Errors::PatientNotFoundError, 'Patient not found'
        end

        patient
      end

      def process_patient_photo(patient_id, photo_params)
        patient_photo = @patient_photo_repository.load(
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
        raise Domain::Errors::PatientPhotoError.new("Error on save patient photo! Error: #{e}")
      end

      def log_photo_error(patient_id, patient_photo)
        Arkham.logger.info(
          "Photo params is not valid: \npatient_id => #{patient_id}\n patient_photo => #{patient_photo}"
        )
      end
    end
  end
end
