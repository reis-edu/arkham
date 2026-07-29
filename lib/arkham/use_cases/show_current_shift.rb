module Arkham
  module UseCases
    class ShowCurrentShift
      def initialize(shift_repository, shift_item_check_repository,
                     list_shift_item_checks = ListShiftItemChecks.new(shift_item_check_repository))
        @shift_repository = shift_repository
        @list_shift_item_checks = list_shift_item_checks
      end

      def execute
        shift = @shift_repository.find_current
        raise Domain::Errors::ShiftNotFoundError, 'No shift found' unless shift

        checks = @list_shift_item_checks.execute(shift.id)
        { shift: shift, checks: checks }
      end
    end
  end
end
