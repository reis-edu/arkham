# frozen_string_literal: true

module Core
  module Commands
    class DestroyPatientCommand
      attr_accessor :id

      def initialize(id)
        @id = id
      end
    end
  end
end
