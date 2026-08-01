module Arkham
  module UseCases
    class DestroyShift
      def initialize(shift_repository)
        @shift_repository = shift_repository
      end

      def execute(id)
        @shift_repository.within_transaction do
          shift = find_shift(id)
          @shift_repository.destroy(shift.id)
        end
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
