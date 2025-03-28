# frozen_string_literal: true

module Arkham
  module Domain
    module Schemas
      class PatientSchema < Dry::Validation::Contract
        params do
          required(:firstname).filled(:str?, min_size?: 2, max_size?: 100)
          required(:lastname).filled(:str?, min_size?: 2, max_size?: 100)
          required(:cpf).filled(:str?)
          required(:gender).filled(:str?)
          optional(:status).filled(:str?)
          optional(:diagnosis).filled(:str?, max_size?: 500)
          optional(:sus).filled(:str?, size?: 15)
          optional(:rg).filled(:str?, max_size?: 20)
          optional(:admission_date).filled(:date)
          optional(:birth_date).filled(:date)
          optional(:photo).hash do
            optional(:photo_base64).filled(:str?)
            optional(:photo_base64_format).filled(:str?)
            optional(:photo_url).filled(:str?, format?: URI::regexp)
            optional(:photo_key).filled(:str?)
          end
        end

        rule(:status) do
          if value.present?
            unless %w[active inactive].include?(value)
              key.failure('must be one of: active, inactive')
            end
          end
        end

        rule(:birth_date) do
          if value.present?
            unless value <= Date.today
              key.failure('must be in the past')
            end
          end
        end

        rule(:admission_date) do
          if value.present? && values[:birth_date].present?
            unless value >= values[:birth_date]
              key.failure('must be after birth date')
            end
          end
        end
      end
    end
  end
end
