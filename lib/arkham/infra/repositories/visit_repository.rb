# frozen_string_literal: true

module Infra
  module Repositories
    class VisitRepository
      attr_reader :visit_model

      def initialize(model = {})
        @visit_model = model.fetch(:patient) { Visit }
      end

      def create(visit)
        visit.save
      end

      def update(visit, attributes)
        visit.update(attributes)
        validate_schedule!(visit.reload)
      end

      def destroy(visit)
        visit.destroy!
      end

      def find_by_id(id)
        visit_model.find_by(id: id)
      end

      private

      def validate_schedule!(visit)
        conflicting_visit = visit_model.fetch_conflicting_visits(visit)
        raise Errors::Visit::ConflictingVisitError unless conflicting_visit.nil?
      end
    end
  end
end
