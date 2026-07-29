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
          if values[:impossible] && value.blank?
            key.failure('is required when impossible is true')
          end
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
