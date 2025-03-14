# frozen_string_literal: true

module Services
  module Visits
    class Update < Factories::Visit
      VISIT_DURATION = Arkham.config[:visits][:duration].freeze

      def initialize(id, attrs, repositories = {})
        super(attrs, repositories)

        @id = id
        @attrs = attrs
      end

      def execute
        visit = visit_repository.find_by_id(@id)
        raise ActiveRecord::RecordNotFound unless visit

        ActiveRecord::Base.transaction do
          visit_repository.update(visit, @attrs)

          visit.id
        end
      end

      def find_visit
        visit = visit_repository.find_by_id(@id)
        raise ActiveRecord::RecordNotFound unless visit

        visit
      end
    end
  end
end
