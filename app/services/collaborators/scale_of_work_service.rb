# frozen_string_literal: true

module Collaborators
  class ScaleOfWorkService
    def create(month, year = Time.current.year)
      Time.new(year, month, 1)
    end

    def find(month, year = Time.current.year)
      raise NotImplementedError
    end

    private

    def days_of_month(reference_date)
      (reference_date.beginning_of_month..reference_date.end_of_month).map(&:mday)
    end
  end
end
