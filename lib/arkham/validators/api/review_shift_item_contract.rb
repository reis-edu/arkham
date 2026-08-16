# frozen_string_literal: true

module Arkham
  module Validators
    module Api
      class ReviewShiftItemContract < Dry::Validation::Contract
        params do
          required(:review_status).filled(:str?)
          optional(:divergence_note).maybe(:str?)
        end

        rule(:review_status) do
          key.failure('must be one of: confirmed, divergent') unless %w[confirmed divergent].include?(value)
        end

        rule(:divergence_note) do
          if values[:review_status] == 'divergent' && value.blank?
            key.failure('is required when review_status is divergent')
          end
        end
      end
    end
  end
end
