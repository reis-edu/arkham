# frozen_string_literal: true

module Infra
  module Repositories
    class VitalSignRepository
      def initialize(model = {})
        @vital_sign = model.fetch(:vital_signs) { VitalSign }
      end

      def save(vital_sign)
        vital_sign.save
      end

      def update(vital_sign, attributes)
        vital_sign.update(attributes)
      end

      def find_by_id(id)
        @vital_sign.find_by(id: id)
      end

      def where(**kwargs)
        @vital_sign.where(kwargs)
      end
    end
  end
end
