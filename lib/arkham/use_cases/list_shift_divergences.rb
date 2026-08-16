# frozen_string_literal: true

module Arkham
  module UseCases
    class ListShiftDivergences
      def initialize(shift_item_check_repository, shift_repository)
        @shift_item_check_repository = shift_item_check_repository
        @shift_repository = shift_repository
      end

      def execute(shift_id)
        find_shift(shift_id)
        @shift_item_check_repository.divergences_for_shift(shift_id)
      end

      private

      def find_shift(shift_id)
        shift = @shift_repository.find_by_id(shift_id)
        raise Domain::Errors::ShiftNotFoundError, 'Shift not found' unless shift

        shift
      end
    end
  end
end
