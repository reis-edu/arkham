# frozen_string_literal: true

module Arkham
  module UseCases
    class CheckShiftItem
      def initialize(shift_item_check_repository, shift_repository)
        @shift_item_check_repository = shift_item_check_repository
        @shift_repository = shift_repository
      end

      def execute(shift_id, shift_item_id, params, actor_id:, actor_group:)
        validated = validate_params(params)
        shift = find_shift(shift_id)
        check = find_check(shift_id, shift_item_id)
        guard_editable!(shift, actor_group)

        attributes = build_attributes(validated, actor_id)

        @shift_item_check_repository.within_transaction do
          @shift_item_check_repository.update_check(check.id, attributes)
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::CheckShiftItemContract.new.call(params)
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

      def guard_editable!(shift, actor_group)
        return unless shift.execution_finalized? || shift.review_finalized?
        return if ::User::SHIFT_MANAGER_GROUPS.include?(actor_group)

        raise Domain::Errors::ShiftEditForbiddenError,
              'Only a shift manager can edit checks after the shift has been finalized'
      end

      # rubocop:disable Metrics/MethodLength
      def build_attributes(validated, actor_id)
        if validated[:impossible]
          {
            checked: false,
            impossible: true,
            impossible_reason: validated[:impossible_reason],
            checked_by_id: actor_id,
            checked_at: Time.current
          }
        else
          {
            checked: validated.fetch(:checked, false),
            impossible: false,
            impossible_reason: nil,
            checked_by_id: actor_id,
            checked_at: Time.current
          }
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
