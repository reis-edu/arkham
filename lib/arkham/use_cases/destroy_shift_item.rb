# frozen_string_literal: true

module Arkham
  module UseCases
    class DestroyShiftItem
      def initialize(shift_item_repository)
        @shift_item_repository = shift_item_repository
      end

      def execute(id)
        @shift_item_repository.within_transaction do
          shift_item = find_shift_item(id)

          if @shift_item_repository.used_in_any_shift?(shift_item.id)
            raise Domain::Errors::ShiftItemInUseError, 'Shift item is already used in a shift and cannot be removed'
          end

          @shift_item_repository.destroy(shift_item.id)
        end
      end

      private

      def find_shift_item(id)
        shift_item = @shift_item_repository.find_by_id(id)
        raise Domain::Errors::ShiftItemNotFoundError, 'Shift item not found' unless shift_item

        shift_item
      end
    end
  end
end
