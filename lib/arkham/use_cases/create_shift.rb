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
        check_duplicate(validated[:shift_date], validated[:shift_type])

        @shift_repository.within_transaction do
          shift_id = @shift_repository.create(validated)
          active_item_ids = @shift_item_repository.find_all_active.map(&:id)
          @shift_item_check_repository.snapshot_for_shift(shift_id, active_item_ids)
          shift_id
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::ShiftContract.new.call(params)
        raise Validators::Errors::ApiValidationError.new(result.errors.to_h) if result.errors.any?

        result.to_h
      end

      def check_duplicate(shift_date, shift_type)
        existing = @shift_repository.find_by_date_and_type(shift_date, shift_type)
        return unless existing

        raise Domain::Errors::ShiftAlreadyExistsError, 'Shift already exists for this date and type!'
      end
    end
  end
end
