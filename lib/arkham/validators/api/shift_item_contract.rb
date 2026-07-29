module Arkham
  module Validators
    module Api
      class ShiftItemContract < Dry::Validation::Contract
        params do
          required(:name).filled(:str?)
          optional(:description).maybe(:str?)
          optional(:active).maybe(:bool?)
        end
      end
    end
  end
end
