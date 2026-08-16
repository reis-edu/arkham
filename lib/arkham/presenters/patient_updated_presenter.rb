# frozen_string_literal: true

module Arkham
  module Presenters
    class PatientUpdatedPresenter
      def initialize(patient_id)
        @patient_id = patient_id
      end

      def to_json(*_args)
        {
          id: @patient_id
        }
      end
    end
  end
end
