module Arkham
  module UseCases
    class UpdatePatient
      def initialize(patient_repository, patient_photo_repository, save_patient_photo = SavePatientPhoto.new(patient_repository, patient_photo_repository))
        @patient_repository = patient_repository
        @patient_photo_repository = patient_photo_repository
        @save_patient_photo = save_patient_photo
      end

      def execute(patient_id, patient_params)
        validated_params = validate_patient_params(patient_params)
        patient = find_patient(patient_id)

        @patient_repository.within_transaction do
          check_duplicate_cpf(patient_id, validated_params[:cpf]) if validated_params[:cpf].present?
          photo_params = validated_params.delete(:photo)
          remove_photo = validated_params.delete(:remove_photo)

          @patient_repository.update(patient_id, validated_params)

          if remove_photo
            remove_patient_photo(patient_id, patient)
          elsif photo_params.present? && photo_params[:photo_base64].present?
            @save_patient_photo.execute(patient_id, photo_params)
          end

          patient_id
        end
      end

      private

      def remove_patient_photo(patient_id, patient)
        @patient_photo_repository.delete(patient.photo_key)
        @patient_repository.update(patient_id, photo_url: nil, photo_key: nil)
      end

      def check_duplicate_cpf(patient_id, new_cpf)
        existing_patient = @patient_repository.find_by_cpf(new_cpf)
        if existing_patient && existing_patient.id != patient_id
          raise Domain::Errors::PatientAlreadyExistsError, 'Patient with this CPF already exists!'
        end
      end

      def validate_patient_params(args)
        patient_params = Validators::Api::PatientContract.new.call(args)
        if patient_params.errors.any?
          raise Validators::Errors::ApiValidationError.new(patient_params.errors.to_h)
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
    end
  end
end
