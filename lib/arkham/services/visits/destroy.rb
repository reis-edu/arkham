# frozen_string_literal: true

module Services
  module Visits
    class Destroy
      def initialize(id, repositories = {})
        @id = id
        @visit_repository = repositories.fetch(:visit) do
          Infra::Repositories::VisitRepository.new
        end
      end

      def execute
        visit = @visit_repository.find_by_id(@id)
        raise ActiveRecord::RecordNotFound unless visit

        ActiveRecord::Base.transaction do
          visit.destroy
        end
      end
    end
  end
end
