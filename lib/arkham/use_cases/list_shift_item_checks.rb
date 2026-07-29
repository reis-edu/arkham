module Arkham
  module UseCases
    class ListShiftItemChecks
      def initialize(shift_item_check_repository)
        @shift_item_check_repository = shift_item_check_repository
      end

      def execute(shift_id)
        @shift_item_check_repository.find_all_for_shift(shift_id)
      end
    end
  end
end
