# frozen_string_literal: true

module Factories
  class Visit
    VISIT_DURATION = Arkham.config[:visits][:duration].freeze

    def initialize(attrs, repositories = {})
      @attrs = attrs
      @repositories = repositories
    end

    def result
      @attrs.merge!({
                      start_date: format_start_date(@attrs['start_date']).to_datetime,
                      end_date: format_end_date(@attrs['start_date']).to_datetime
                    })
      visit_validation = Schemas::Visit.new.call(@attrs)
      return visit_validation.to_h unless visit_validation.errors.any?

      raise Api::Errors::SchemaValidationError, visit_validation.errors
    end

    def visit_repository
      @repositories.fetch(:visit) do
        Infra::Repositories::VisitRepository.new
      end
    end

    private

    def format_start_date(string_date)
      date = string_date.to_datetime
      Time.zone.local(date.year, date.month, date.day, date.hour, date.min)
    end

    def format_end_date(string_date)
      date = string_date.to_datetime
      Time.zone.local(date.year, date.month, date.day, date.hour, date.min) + VISIT_DURATION.minutes
    end
  end
end
