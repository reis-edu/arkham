module Core
  module Commands
    class CreatePatientCommand
      attr_accessor :patient

      def initialize(patient:)
        @patient = patient
      end
    end
  end
end