module Core
  module CommandHandlers
    class CreatePatientCommandHandler
      def initialize(repositories = {})
        @patient_repository = repositories.fetch(:patient) { Infra::Repositories::PatientRepository.new }
      end

      def create_patient(create_patient_command)
        patient = Patient.new(create_patient_command.patient)

        raise_patient_existent_error if Patient.exists?(cpf: patient.cpf)

        ActiveRecord::Base.transaction do
          @patient_repository.save(patient)

          patient.id
        end
      end

      private

      def raise_patient_existent_error
        raise Errors::Patient::PatientAlreadyExistsError, "Patient with this CPF already exists!"
      end
    end
  end
end