module Arkham
  module Validators
    module Api
      class CopyLastShiftContract < Dry::Validation::Contract
        params do
          required(:shift_date).filled(:str?)
          required(:shift_type).filled(:str?)
        end

        rule(:shift_type) do
          unless ::Shift::TYPES.include?(value)
            key.failure("must be one of: #{::Shift::TYPES.join(', ')}")
          end
        end
      end
    end
  end
end
