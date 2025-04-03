module Arkham
  module Presenters
    class PatientCreatedPresenter
      def initialize(patient_id)
        @patient_id = patient_id
      end

      def to_json
        {
          id: @patient_id
        }
      end
    end
  end
end
