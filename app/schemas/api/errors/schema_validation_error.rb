module Api
  module Errors
    class SchemaValidationError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
        super
      end
    end
  end
end