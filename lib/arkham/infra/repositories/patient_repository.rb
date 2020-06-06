# frozen_string_literal: true

module Infra
  module Repositories
    class PatientRepository
      def initialize(model = {})
        @patient = model.fetch(:patient) { Patient }
      end

      def save(patient)
        patient.save
      end

      def find_by_id(id)
        @patient.find_by(id: id)
      end
    end
  end
end
