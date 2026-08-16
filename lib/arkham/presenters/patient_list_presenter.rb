# frozen_string_literal: true

module Arkham
  module Presenters
    class PatientListPresenter
      def initialize(patients)
        @patients = patients
      end

      def to_json(*_args)
        {
          patients: @patients.map { |patient| PatientPresenter.new(patient).to_json }
        }
      end
    end
  end
end
