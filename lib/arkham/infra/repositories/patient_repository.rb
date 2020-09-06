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

      def update(patient, attributes)
        patient.update(attributes)
      end

      def activate!(patient)
        patient.update(status: 'active')
      end

      def inactivate!(patient)
        patient.update(status: 'inactive')
      end

      def find_by_id(id)
        @patient.find_by(id: id)
      end
    end
  end
end
