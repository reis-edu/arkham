module Arkham
  module UseCases
    class UpdateShift
      def initialize(shift_repository)
        @shift_repository = shift_repository
      end

      def execute(id, params)
        validated = validate_params(params)
        shift = find_shift(id)
        check_duplicate(validated, shift)

        @shift_repository.within_transaction do
          @shift_repository.update(shift.id, validated)
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::UpdateShiftContract.new.call(params)
        raise Validators::Errors::ApiValidationError.new(result.errors.to_h) if result.errors.any?

        result.to_h
      end

      def find_shift(id)
        shift = @shift_repository.find_by_id(id)
        raise Domain::Errors::ShiftNotFoundError, 'Shift not found' unless shift

        shift
      end

      def check_duplicate(validated, shift)
        shift_date = validated[:shift_date] || shift.shift_date
        shift_type = validated[:shift_type] || shift.shift_type
        existing = @shift_repository.find_by_date_and_type(shift_date, shift_type)
        return unless existing
        return if existing.id == shift.id

        raise Domain::Errors::ShiftAlreadyExistsError, 'Shift already exists for this date and type!'
      end
    end
  end
end
