module Core
  module Schemas
    class Patient < Dry::Validation::Contract
      params do
        required(:firstname).filled(:str?)
        required(:lastname).filled(:str?)
        required(:cpf).filled(:str?)
        required(:gender).filled(:str?)
        optional(:diagnosis).filled(:str?)
        optional(:sus).filled(:str?)
        optional(:rg).filled(:str?)
        optional(:admission_date).filled(:date)
        optional(:birth_date).filled(:date)
        optional(:created_at).filled(:date_time?)
        optional(:updated_at).filled(:date_time?)
  
        optional(:photo).hash do
          optional(:photo_base64).filled(:str?)
          optional(:photo_base64_format).filled(:str?)
          optional(:photo_url).filled(:str?)
          optional(:photo_key).filled(:str?)
        end
      end
    end
  end
end