module Arkham
  module UseCases
    class CreatePatient
      def initialize(patient_repository, patient_photo_repository)
        @patient_repository = patient_repository
        @patient_photo_repository = patient_photo_repository
      end
      
      def execute(patient_params)
        new_patient = validate_patient_params(patient_params)
        check_duplicate_cpf(new_patient[:cpf])

        @patient_repository.within_transaction do
          photo_params = new_patient.delete(:photo)
          patient_id = @patient_repository.create(new_patient)

          if photo_params.present? && photo_params[:photo_base64].present?
            save_patient_photo(patient_id, photo_params)
          end

          patient_id
        end
      end

      private
      
      def validate_patient_params(params)
        new_patient = Validators::Api::PatientContract.new.call(params)
        if new_patient.errors.any?
          Rails.logger.error("Validators::Errors::ApiValidationError #{new_patient.errors.to_h}")
          raise Validators::Errors::ApiValidationError.new(new_patient.errors.to_h), 'Patient params are not valid!'
        end

        new_patient.to_h
      end
      
      def check_duplicate_cpf(new_cpf)
        existing_patient = @patient_repository.find_by_cpf(new_cpf)
        if existing_patient
          raise Domain::Errors::PatientAlreadyExistsError, 'Patient with this CPF already exists!'
        end
      end

      def save_patient_photo(patient_id, photo_params)
        patient_photo = @patient_photo_repository.save(
          patient_id, 
          photo_params[:photo_base64],
          photo_params[:photo_base64_format]
        )

        update_patient(patient_photo, patient_id)
      end
      
      def update_patient(patient_photo, patient_id)
        @patient_repository.update(
          patient_id,
          {
            photo_url: patient_photo.photo_url,
            photo_key: patient_photo.photo_key
          }
        )
      end
    end
  end
end
