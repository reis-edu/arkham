module Arkham
  module UseCases
    class FinalizeShiftExecution
      def initialize(shift_repository)
        @shift_repository = shift_repository
      end

      def execute(shift_id, params, actor_id:)
        validated = validate_params(params)
        shift = find_shift(shift_id)
        guard_open!(shift)

        @shift_repository.within_transaction do
          @shift_repository.finalize_execution(shift.id, execution_note: validated[:execution_note], by_id: actor_id)
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::FinalizeShiftExecutionContract.new.call(params)
        raise Validators::Errors::ApiValidationError.new(result.errors.to_h) if result.errors.any?

        result.to_h
      end

      def find_shift(shift_id)
        shift = @shift_repository.find_by_id(shift_id)
        raise Domain::Errors::ShiftNotFoundError, 'Shift not found' unless shift

        shift
      end

      def guard_open!(shift)
        return if shift.open?

        raise Domain::Errors::ShiftAlreadyFinalizedError, 'Shift execution has already been finalized'
      end
    end
  end
end
