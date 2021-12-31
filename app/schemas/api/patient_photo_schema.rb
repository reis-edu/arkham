# frozen_string_literal: true

module Api
  class PatientPhotoSchema < Dry::Validation::Contract
    params do
      optional(:photo_base64).filled(:str?)
      optional(:photo_base64_format).filled(:str?)
      optional(:photo_url).filled(:str?)
      optional(:photo_key).filled(:str?)
    end
  end
end
