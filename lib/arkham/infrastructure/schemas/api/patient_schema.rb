# frozen_string_literal: true

module Arkham
  module Infrastructure
    module Schemas
      module Api
        class PatientSchema < Dry::Validation::Contract
          params do
            required(:firstname).filled(:str?)
            required(:lastname).filled(:str?)
            required(:cpf).filled(:str?)
            required(:gender).filled(:str?)
            optional(:status).filled(:str?)
            optional(:diagnosis).filled(:str?)
            optional(:sus).filled(:str?)
            optional(:rg).filled(:str?)
            optional(:admission_date).filled(:str?)
            optional(:birth_date).filled(:str?)
            optional(:photo).hash do
              optional(:photo_base64).filled(:str?)
              optional(:photo_base64_format).filled(:str?)
              optional(:photo_url).filled(:str?)
              optional(:photo_key).filled(:str?)
            end
          end

          rule(:gender) do
            unless %w[m f].include?(value)
              key.failure('must be one of: male, female, other')
            end
          end
        end
      end
    end
  end
end
