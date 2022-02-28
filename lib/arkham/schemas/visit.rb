# frozen_string_literal: true

module Schemas
  class Visit < Dry::Validation::Contract
    params do
      required(:visitor_id).filled(:str?)
      required(:patient_id).filled(:str?)
      required(:start_date).filled(:date_time?)
      required(:end_date).filled(:date_time?)
      optional(:description)
    end
  end
end
