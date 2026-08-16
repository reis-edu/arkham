# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class FinalizeShiftExecutionContract < Dry::Validation::Contract
        params do
          optional(:execution_note).maybe(:str?)
        end
      end
    end
  end
end
