# frozen_string_literal: true

module Validation
  module Schema
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    class JSON < Dry::Validation::Schema::JSON
      configure do
        config.messages = :i18n
      end
    end

    class Params < Dry::Validation::Schema::Params
      configure do
        config.messages = :i18n
      end
    end

    class Dry::Validation::Messages::I18n
      def default_locale
        :en
      end
    end

    module ClassMethods
      def JsonSchema(base = JSON, **options, &block)
        Dry::Validation.JSON(base, options, &block)
      end

      def ParamsSchema(base = Params, **options, &block)
        Dry::Validation.Params(base, options, &block)
      end
    end
  end
end
