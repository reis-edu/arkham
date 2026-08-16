# frozen_string_literal: true

module Arkham
  module UseCases
    class CreateShift
      def initialize(shift_repository, shift_item_repository, shift_item_check_repository)
        @shift_repository = shift_repository
        @shift_item_repository = shift_item_repository
        @shift_item_check_repository = shift_item_check_repository
      end

      def execute(params)
        validated = validate_params(params)
        item_ids = validated[:shift_item_ids].uniq
        check_duplicate(validated[:shift_date], validated[:shift_type])
        check_items_exist(item_ids)

        @shift_repository.within_transaction do
          shift_id = @shift_repository.create(shift_date: validated[:shift_date], shift_type: validated[:shift_type])
          @shift_item_check_repository.snapshot_for_shift(shift_id, item_ids)
          shift_id
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::ShiftContract.new.call(params)
        raise Validators::Errors::ApiValidationError, result.errors.to_h if result.errors.any?

        result.to_h
      end

      def check_duplicate(shift_date, shift_type)
        existing = @shift_repository.find_by_date_and_type(shift_date, shift_type)
        return unless existing

        raise Domain::Errors::ShiftAlreadyExistsError, 'Shift already exists for this date and type!'
      end

      def check_items_exist(item_ids)
        return if @shift_item_repository.all_exist?(item_ids)

        raise Domain::Errors::ShiftItemNotFoundError, 'One or more shift items do not exist'
      end
    end
  end
end
