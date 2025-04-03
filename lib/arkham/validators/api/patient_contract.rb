module Arkham
  module Validators
    module Api
      class PatientContract < Dry::Validation::Contract
        params do
          required(:firstname).filled(:str?)
          required(:lastname).filled(:str?)
          required(:cpf).filled(:str?)
          required(:gender).filled(:str?)
          optional(:status).maybe(:str?)
          optional(:diagnosis).maybe(:str?)
          optional(:sus).maybe(:str?)
          optional(:rg).maybe(:str?)
          optional(:admission_date).maybe(:str?)
          optional(:birth_date).maybe(:str?)
          optional(:photo).hash do
            optional(:photo_base64).maybe(:str?)
            optional(:photo_base64_format).maybe(:str?)
            optional(:photo_url).maybe(:str?)
            optional(:photo_key).maybe(:str?)
          end
        end

        rule(:gender) do
          unless %w[m f].include?(value)
            key.failure('must be one of: male, female')
          end
        end

        rule(:status) do
          if value.present?
            unless %w[active inactive].include?(value)
              key.failure('must be one of: active, inactive')
            end
          end
        end
      end
    end
  end
end
