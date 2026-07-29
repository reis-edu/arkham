module Arkham
  module UseCases
    class ShowShiftItem
      def initialize(shift_item_repository)
        @shift_item_repository = shift_item_repository
      end

      def execute(id)
        shift_item = @shift_item_repository.find_by_id(id)
        raise Domain::Errors::ShiftItemNotFoundError, 'Shift item not found' unless shift_item

        shift_item
      end
    end
  end
end
