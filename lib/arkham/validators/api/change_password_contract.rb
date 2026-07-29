module Arkham
  module Validators
    module Api
      class ChangePasswordContract < Dry::Validation::Contract
        params do
          required(:current_password).filled(:str?)
          required(:new_password).filled(:str?)
        end

        rule(:new_password) do
          key.failure('must have at least 6 characters') if value.length < 6
        end
      end
    end
  end
end
