# frozen_string_literal: true

module Arkham
  module UseCases
    class CopyLastShift
      def initialize(shift_repository, shift_item_repository, shift_item_check_repository,
                     create_shift = CreateShift.new(shift_repository, shift_item_repository,
                                                    shift_item_check_repository))
        @shift_repository = shift_repository
        @shift_item_check_repository = shift_item_check_repository
        @create_shift = create_shift
      end

      def execute(params)
        validated = validate_params(params)
        previous_shift = find_previous_shift(validated[:shift_type])
        item_ids = @shift_item_check_repository.find_all_for_shift(previous_shift.id).map(&:shift_item_id)

        @create_shift.execute(
          shift_date: validated[:shift_date],
          shift_type: validated[:shift_type],
          shift_item_ids: item_ids
        )
      end

      private

      def validate_params(params)
        result = Validators::Api::CopyLastShiftContract.new.call(params)
        raise Validators::Errors::ApiValidationError, result.errors.to_h if result.errors.any?

        result.to_h
      end

      def find_previous_shift(shift_type)
        shift = @shift_repository.find_last_by_type(shift_type)
        unless shift
          raise Domain::Errors::ShiftCopySourceNotFoundError, 'There is no previous shift of this type to copy from'
        end

        shift
      end
    end
  end
end
