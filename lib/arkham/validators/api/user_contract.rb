# frozen_string_literal: true

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
          key.failure('must follow the pattern name.lastname') unless value.match?(::User::LOGIN_FORMAT)
        end

        rule(:group) do
          key.failure("must be one of: #{::User::GROUPS.join(', ')}") unless ::User::GROUPS.include?(value)
        end
      end
    end
  end
end
