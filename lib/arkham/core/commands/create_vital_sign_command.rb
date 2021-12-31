# frozen_string_literal: true

module Core
  module Commands
    class CreateVitalSignCommand
      attr_accessor :patient, :vital_sign

      VITAL_SIGN_PERIODS = %w[morning evening night].freeze

      def initialize(params)
        define_vital_sign!(params)
        define_patient!(params['patient_id'])
        validate_period!
        validate_vital_sign_exists!
      end

      private

      def define_vital_sign!(params)
        vital_sign_schema = Api::VitalSignSchema.new.call(params)
        raise Api::Errors::SchemaValidationError, vital_sign_schema.errors if vital_sign_schema.errors.any?

        @vital_sign = vital_sign_schema.to_h
      end

      def define_patient!(patient_id)
        patient_repository = Infra::Repositories::PatientRepository.new
        @patient = patient_repository.find_by_id(patient_id)

        raise Errors::Patient::PatientNotFoundError, 'Patient not found' unless @patient
      end

      def validate_period!
        valid_period = vital_sign[:period].in?(VITAL_SIGN_PERIODS)

        raise Errors::VitalSign::VitalSignPeriodNotFoundError, 'Period not found' unless valid_period
      end

      def validate_vital_sign_exists!
        vital_sign_repository = Infra::Repositories::VitalSignRepository.new
        vital_sign = vital_sign_repository.where(date: self.vital_sign[:date],
                                                 period: self.vital_sign[:period],
                                                 patient_id: patient.id).take

        raise Errors::VitalSign::VitalSignAlreadyExistsError, 'Vital Sign already exist' if vital_sign
      end
    end
  end
end
