# frozen_string_literal: true

module Api
  VitalSignSchema = Arkham.JsonSchema do
    required(:patient_id).filled(:str?)
    required(:period).filled(:str?)
    required(:date).filled(:date?)
    optional(:pa).filled(:str?)
    optional(:bpm).filled(:str?)
    optional(:saturation).filled(:int?)
    optional(:blood_glucose).filled(:str?)
    optional(:temperature).filled(:float?)
    optional(:created_at).filled(:date_time?)
    optional(:updated_at).filled(:date_time?)
    optional(:diuresis).filled(:str?)
    optional(:feces).filled(:str?)
  end
end
