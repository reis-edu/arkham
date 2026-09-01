# frozen_string_literal: true

module Arkham
  module UseCases
    class UpdateShift
      def initialize(shift_repository)
        @shift_repository = shift_repository
      end

      def execute(id, params)
        validated = validate_params(params)
        shift = find_shift(id)

        @shift_repository.within_transaction do
          @shift_repository.update(shift.id, validated)
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::UpdateShiftContract.new.call(params)
        raise Validators::Errors::ApiValidationError, result.errors.to_h if result.errors.any?

        result.to_h
      end

      def find_shift(id)
        shift = @shift_repository.find_by_id(id)
        raise Domain::Errors::ShiftNotFoundError, 'Shift not found' unless shift

        shift
      end
    end
  end
end
