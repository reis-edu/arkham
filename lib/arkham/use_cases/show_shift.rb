# frozen_string_literal: true

module Arkham
  module UseCases
    class ShowShift
      def initialize(shift_repository, shift_item_check_repository,
                     list_shift_item_checks = ListShiftItemChecks.new(shift_item_check_repository))
        @shift_repository = shift_repository
        @list_shift_item_checks = list_shift_item_checks
      end

      def execute(id)
        shift = find_shift(id)
        checks = @list_shift_item_checks.execute(shift.id)
        { shift: shift, checks: checks }
      end

      private

      def find_shift(id)
        shift = @shift_repository.find_by_id(id)
        raise Domain::Errors::ShiftNotFoundError, 'Shift not found' unless shift

        shift
      end
    end
  end
end
