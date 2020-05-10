# frozen_string_literal: true

FactoryBot.define do

  factory :patient, class: 'Patient' do
    name           { 'Pedra Serode' }
    sus            { '123456784343' }
    cpf            { '123.456.123-12' }
    rg             { '12.123.123-2' }
    birth_date     { DateTime.new(1928, 10, 15) }
    diagnosis      { 'Diabetes' }
    admission_date { DateTime.now }
    photo_url      { 'http://www.photo.com.br' }

    trait :with_medicament_managements do
      after(:build) do |p, evaluator|
        create_list(:medicament_management, 2, patient: p)
      end
    end
  end
end