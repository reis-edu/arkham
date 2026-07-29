module Arkham
  module UseCases
    class ListShifts
      def initialize(shift_repository)
        @shift_repository = shift_repository
      end

      def execute(filter_params = {})
        @shift_repository.find_all(filter_params)
      end
    end
  end
end
