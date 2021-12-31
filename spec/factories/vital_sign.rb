# frozen_string_literal: true

FactoryBot.define do
  factory :vital_sign, class: 'VitalSign' do
    pa            { '14/8' }
    period        { 'morning' }
    bpm           { 90 }
    saturation    { 93 }
    blood_glucose { nil }
    temperature   { 36.8 }
    date          { Date.new(2021, 5, 30) }
    patient       { Patient.first || association(:patient) }
  end
end
