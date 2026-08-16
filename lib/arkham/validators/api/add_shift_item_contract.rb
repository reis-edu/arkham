# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class AddShiftItemContract < Dry::Validation::Contract
        params do
          required(:shift_item_id).filled(:str?)
        end
      end
    end
  end
end
