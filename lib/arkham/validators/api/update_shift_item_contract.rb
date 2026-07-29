module Arkham
  module Validators
    module Api
      class UpdateShiftItemContract < Dry::Validation::Contract
        params do
          optional(:name).maybe(:str?)
          optional(:description).maybe(:str?)
          optional(:active).maybe(:bool?)
        end
      end
    end
  end
end
