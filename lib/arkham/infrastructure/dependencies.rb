module Arkham
  module Infrastructure
    class Dependencies
      def self.patient_repository
        @patient_repository ||= Adapters::Persistence::ActiveRecordPatientRepository.new
      end

      def self.patient_photo_repository
        @patient_photo_repository ||= Adapters::Persistence::ActiveRecordPatientPhotoRepository.new
      end

      def self.list_patients_use_case
        @list_patients_use_case ||= Core::UseCases::ListPatients.new(patient_repository)
      end

      def self.create_patient_use_case
        @create_patient_use_case ||= Core::UseCases::CreatePatient.new(patient_repository, patient_photo_repository)
      end

      def self.update_patient_use_case
        @update_patient_use_case ||= Core::UseCases::UpdatePatient.new(patient_repository, patient_photo_repository)
      end

      def self.destroy_patient_use_case
        @destroy_patient_use_case ||= Core::UseCases::DestroyPatient.new(patient_repository)
      end

      def self.activate_patient_use_case
        @activate_patient_use_case ||= Core::UseCases::ActivatePatient.new(patient_repository)
      end

      def self.inactivate_patient_use_case
        @inactivate_patient_use_case ||= Core::UseCases::InactivatePatient.new(patient_repository)
      end
    end
  end
end
