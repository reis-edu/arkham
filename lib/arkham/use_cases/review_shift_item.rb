# frozen_string_literal: true

module Arkham
  module UseCases
    class ReviewShiftItem
      def initialize(shift_item_check_repository, shift_repository)
        @shift_item_check_repository = shift_item_check_repository
        @shift_repository = shift_repository
      end

      def execute(shift_id, shift_item_id, params, actor_id:, actor_group:)
        validated = validate_params(params)
        shift = find_shift(shift_id)
        check = find_check(shift_id, shift_item_id)
        guard_ready_for_review!(shift)
        guard_editable!(shift, actor_group)

        attributes = {
          review_status: validated[:review_status],
          divergence_note: validated[:review_status] == 'divergent' ? validated[:divergence_note] : nil,
          reviewed_by_id: actor_id,
          reviewed_at: Time.current
        }

        @shift_item_check_repository.within_transaction do
          @shift_item_check_repository.update_review(check.id, attributes)
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::ReviewShiftItemContract.new.call(params)
        raise Validators::Errors::ApiValidationError, result.errors.to_h if result.errors.any?

        result.to_h
      end

      def find_shift(shift_id)
        shift = @shift_repository.find_by_id(shift_id)
        raise Domain::Errors::ShiftNotFoundError, 'Shift not found' unless shift

        shift
      end

      def find_check(shift_id, shift_item_id)
        check = @shift_item_check_repository.find_by_shift_and_item(shift_id, shift_item_id)
        raise Domain::Errors::ShiftItemCheckNotFoundError, 'Shift item check not found' unless check

        check
      end

      def guard_ready_for_review!(shift)
        return unless shift.open?

        raise Domain::Errors::ShiftNotReadyForReviewError, 'Shift execution must be finalized before it can be reviewed'
      end

      def guard_editable!(shift, actor_group)
        return unless shift.review_finalized?
        return if ::User::SHIFT_MANAGER_GROUPS.include?(actor_group)

        raise Domain::Errors::ShiftEditForbiddenError,
              'Only a shift manager can edit reviews after the review has been finalized'
      end
    end
  end
end
