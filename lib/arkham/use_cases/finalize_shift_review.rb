# frozen_string_literal: true

module Arkham
  module UseCases
    class FinalizeShiftReview
      def initialize(shift_repository)
        @shift_repository = shift_repository
      end

      def execute(shift_id, actor_id:)
        shift = find_shift(shift_id)
        guard_ready!(shift)

        @shift_repository.within_transaction do
          @shift_repository.finalize_review(shift.id, by_id: actor_id)
        end
      end

      private

      def find_shift(shift_id)
        shift = @shift_repository.find_by_id(shift_id)
        raise Domain::Errors::ShiftNotFoundError, 'Shift not found' unless shift

        shift
      end

      def guard_ready!(shift)
        if shift.open?
          raise Domain::Errors::ShiftNotReadyForReviewError,
                'Shift execution must be finalized before the review can be finalized'
        end

        return unless shift.review_finalized?

        raise Domain::Errors::ShiftAlreadyFinalizedError,
              'Shift review has already been finalized'
      end
    end
  end
end
