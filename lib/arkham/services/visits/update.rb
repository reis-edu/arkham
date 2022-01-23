# frozen_string_literal: true

module Services
  module Visits
    class Update < Factories::Visit
      VISIT_DURATION = Arkham.config.visits['duration'].freeze

      def initialize(id, attrs, repositories = {})
        super(attrs, repositories)
        @id = id
      end

      def execute
        visit = visit_repository.find_by_id(@id)
        raise ActiveRecord::RecordNotFound unless visit

        ActiveRecord::Base.transaction do
          visit_repository.update(visit, result)

          visit.id
        end
      end
    end
  end
end
