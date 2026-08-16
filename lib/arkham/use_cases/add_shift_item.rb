# frozen_string_literal: true

module Arkham
  module UseCases
    class AddShiftItem
      def initialize(shift_repository, shift_item_repository, shift_item_check_repository)
        @shift_repository = shift_repository
        @shift_item_repository = shift_item_repository
        @shift_item_check_repository = shift_item_check_repository
      end

      def execute(shift_id, params)
        validated = validate_params(params)
        shift = find_shift(shift_id)
        guard_open!(shift)
        find_shift_item(validated[:shift_item_id])
        check_not_already_present(shift_id, validated[:shift_item_id])

        @shift_item_check_repository.within_transaction do
          @shift_item_check_repository.create(shift_id, validated[:shift_item_id])
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::AddShiftItemContract.new.call(params)
        raise Validators::Errors::ApiValidationError, result.errors.to_h if result.errors.any?

        result.to_h
      end

      def find_shift(shift_id)
        shift = @shift_repository.find_by_id(shift_id)
        raise Domain::Errors::ShiftNotFoundError, 'Shift not found' unless shift

        shift
      end

      def guard_open!(shift)
        return if shift.open?

        raise Domain::Errors::ShiftAlreadyFinalizedError,
              'Shift items can only be added or removed while the shift is open'
      end

      def find_shift_item(shift_item_id)
        shift_item = @shift_item_repository.find_by_id(shift_item_id)
        raise Domain::Errors::ShiftItemNotFoundError, 'Shift item not found' unless shift_item

        shift_item
      end

      def check_not_already_present(shift_id, shift_item_id)
        existing = @shift_item_check_repository.find_by_shift_and_item(shift_id, shift_item_id)
        return unless existing

        raise Domain::Errors::ShiftItemCheckAlreadyExistsError, 'This item is already part of the shift'
      end
    end
  end
end
