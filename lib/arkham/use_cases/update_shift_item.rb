module Arkham
  module UseCases
    class UpdateShiftItem
      def initialize(shift_item_repository)
        @shift_item_repository = shift_item_repository
      end

      def execute(id, params)
        validated = validate_params(params)
        shift_item = find_shift_item(id)
        check_duplicate_name(validated[:name], shift_item.id) if validated[:name]

        @shift_item_repository.within_transaction do
          @shift_item_repository.update(shift_item.id, validated)
        end
      end

      private

      def validate_params(params)
        result = Validators::Api::UpdateShiftItemContract.new.call(params)
        raise Validators::Errors::ApiValidationError.new(result.errors.to_h) if result.errors.any?

        result.to_h
      end

      def find_shift_item(id)
        shift_item = @shift_item_repository.find_by_id(id)
        raise Domain::Errors::ShiftItemNotFoundError, 'Shift item not found' unless shift_item

        shift_item
      end

      def check_duplicate_name(name, id)
        existing = @shift_item_repository.find_by_name(name)
        return unless existing
        return if existing.id == id

        raise Domain::Errors::ShiftItemAlreadyExistsError, 'Shift item with this name already exists!'
      end
    end
  end
end
