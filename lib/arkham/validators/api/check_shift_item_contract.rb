# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class CheckShiftItemContract < Dry::Validation::Contract
        params do
          optional(:checked).maybe(:bool?)
          optional(:impossible).maybe(:bool?)
          optional(:impossible_reason).maybe(:str?)
        end

        rule(:impossible_reason) do
          key.failure('is required when impossible is true') if values[:impossible] && value.blank?
        end

        rule(:checked, :impossible) do
          if values[:checked] && values[:impossible]
            key(:impossible).failure('cannot be true at the same time as checked')
          end
        end
      end
    end
  end
end
