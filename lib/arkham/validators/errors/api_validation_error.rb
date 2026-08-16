# frozen_string_literal: true

module Arkham
  module Validators
    module Errors
      class ApiValidationError < StandardError
        def initialize(errors)
          @errors = errors
          super("API validation failed: #{errors}")
        end

        attr_reader :errors
      end
    end
  end
end
