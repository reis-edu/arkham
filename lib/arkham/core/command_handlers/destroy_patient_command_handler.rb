# frozen_string_literal: true

module Core
  module CommandHandlers
    class DestroyPatientCommandHandler
      def initialize(repositories = {})
        @patient_repository = repositories.fetch(:patient) { Infra::Repositories::PatientRepository.new }
      end

      def execute(command)
        patient = @patient_repository.find_by_id(command.id)
        raise ActiveRecord::RecordNotFound unless patient
        ActiveRecord::Base.transaction do
          patient.destroy
        end
      end
    end
  end
end
