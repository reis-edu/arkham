# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class CopyLastShiftContract < Dry::Validation::Contract
        params do
          required(:shift_date).filled(:str?)
          required(:shift_type).filled(:str?)
        end

        rule(:shift_type) do
          key.failure("must be one of: #{::Shift::TYPES.join(', ')}") unless ::Shift::TYPES.include?(value)
        end
      end
    end
  end
end
