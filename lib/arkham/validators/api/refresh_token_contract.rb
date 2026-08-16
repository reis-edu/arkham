# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class RefreshTokenContract < Dry::Validation::Contract
        params do
          required(:refresh_token).filled(:str?)
        end
      end
    end
  end
end
