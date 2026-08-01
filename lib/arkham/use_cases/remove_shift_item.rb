module Arkham
  module UseCases
    class RemoveShiftItem
      def initialize(shift_repository, shift_item_check_repository)
        @shift_repository = shift_repository
        @shift_item_check_repository = shift_item_check_repository
      end

      def execute(shift_id, shift_item_id)
        shift = find_shift(shift_id)
        guard_open!(shift)
        check = find_check(shift_id, shift_item_id)

        @shift_item_check_repository.within_transaction do
          @shift_item_check_repository.destroy(check.id)
        end
      end

      private

      def find_shift(shift_id)
        shift = @shift_repository.find_by_id(shift_id)
        raise Domain::Errors::ShiftNotFoundError, 'Shift not found' unless shift

        shift
      end

      def guard_open!(shift)
        return if shift.open?

        raise Domain::Errors::ShiftAlreadyFinalizedError, 'Shift items can only be added or removed while the shift is open'
      end

      def find_check(shift_id, shift_item_id)
        check = @shift_item_check_repository.find_by_shift_and_item(shift_id, shift_item_id)
        raise Domain::Errors::ShiftItemCheckNotFoundError, 'Shift item check not found' unless check

        check
      end
    end
  end
end
