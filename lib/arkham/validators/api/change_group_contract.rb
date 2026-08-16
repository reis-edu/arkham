# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class ChangeGroupContract < Dry::Validation::Contract
        params do
          required(:group).filled(:str?)
        end

        rule(:group) do
          key.failure("must be one of: #{::User::GROUPS.join(', ')}") unless ::User::GROUPS.include?(value)
        end
      end
    end
  end
end
