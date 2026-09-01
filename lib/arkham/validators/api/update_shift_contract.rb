# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class UpdateShiftContract < Dry::Validation::Contract
        params do
          optional(:shift_date).maybe(:str?)
          optional(:shift_type).maybe(:str?)
          optional(:title).maybe(:str?)
        end

        rule(:shift_type) do
          if value.present? && !::Shift::TYPES.include?(value)
            key.failure("must be one of: #{::Shift::TYPES.join(', ')}")
          end
        end
      end
    end
  end
end
