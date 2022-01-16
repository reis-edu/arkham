# frozen_string_literal: true

module Services
  module Visits
    class Create < Factories::Visit
      VISIT_DURATION = Arkham.config.visits['duration'].freeze

      def initialize(attrs, repositories = {})
        super
      end

      def execute
        new_visit = Visit.new(result)
        ActiveRecord::Base.transaction do
          visit_repository.create(new_visit)

          new_visit.id
        end
      end
    end
  end
end
