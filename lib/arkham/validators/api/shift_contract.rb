# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class ShiftContract < Dry::Validation::Contract
        params do
          required(:shift_date).filled(:str?)
          required(:shift_type).filled(:str?)
          required(:shift_item_ids).array(:str?)
        end

        rule(:shift_type) do
          key.failure("must be one of: #{::Shift::TYPES.join(', ')}") unless ::Shift::TYPES.include?(value)
        end

        rule(:shift_item_ids) do
          key.failure('must contain at least one shift item id') if value.empty?
        end
      end
    end
  end
end
