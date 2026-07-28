module Arkham
  module Validators
    module Api
      class ChangeGroupContract < Dry::Validation::Contract
        params do
          required(:group).filled(:str?)
        end

        rule(:group) do
          unless ::User::GROUPS.include?(value)
            key.failure("must be one of: #{::User::GROUPS.join(', ')}")
          end
        end
      end
    end
  end
end
