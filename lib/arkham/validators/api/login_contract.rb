# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class LoginContract < Dry::Validation::Contract
        params do
          required(:login).filled(:str?)
          required(:password).filled(:str?)
        end
      end
    end
  end
end
