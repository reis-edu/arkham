module Arkham
  module Validators
    module Api
      class UserContract < Dry::Validation::Contract
        params do
          required(:name).filled(:str?)
          required(:login).filled(:str?)
          required(:email).filled(:str?)
          required(:group).filled(:str?)
        end

        rule(:login) do
          unless value.match?(::User::LOGIN_FORMAT)
            key.failure('must follow the pattern name.lastname')
          end
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
