module Arkham
  module Validators
    module Api
      class ReviewShiftItemContract < Dry::Validation::Contract
        params do
          required(:review_status).filled(:str?)
          optional(:divergence_note).maybe(:str?)
        end

        rule(:review_status) do
          unless %w[confirmed divergent].include?(value)
            key.failure('must be one of: confirmed, divergent')
          end
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
