# frozen_string_literal: true

module Services
  module Patients
    class Destroy
      def initialize(id, repositories = {})
        @id = id
        @patient_repository = repositories.fetch(:patient) do
          Infra::Repositories::PatientRepository.new
        end
      end

      def destroy
        patient = @patient_repository.find_by_id(@id)
        raise ActiveRecord::RecordNotFound unless patient

        ActiveRecord::Base.transaction do
          patient.destroy
        end
      end
    end
  end
end
