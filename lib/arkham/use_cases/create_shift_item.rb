module Arkham
  module UseCases
    class CreateShiftItem
      def initialize(shift_item_repository)
        @shift_item_repository = shift_item_repository
      end

      def execute(params)
        validated = validate_params(params)
        check_duplicate_name(validated[:name])

        @shift_item_repository.within_transaction do
          @shift_item_repository.create(validated)
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::ShiftItemContract.new.call(params)
        raise Validators::Errors::ApiValidationError.new(result.errors.to_h) if result.errors.any?

        result.to_h
      end

      def check_duplicate_name(name)
        existing = @shift_item_repository.find_by_name(name)
        return unless existing

        raise Domain::Errors::ShiftItemAlreadyExistsError, 'Shift item with this name already exists!'
      end
    end
  end
end
