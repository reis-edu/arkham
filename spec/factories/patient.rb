# frozen_string_literal: true

FactoryBot.define do
  factory :patient, class: 'Patient' do
    firstname      { 'Pedra' }
    lastname       { 'Cerode' }
    sus            { '123456784343' }
    cpf            { CpfUtils.cpf }
    gender         { 'female' }
    rg             { '12.123.123-2' }
    birth_date     { DateTime.new(1928, 10, 15) }
    diagnosis      { 'Diabetes' }
    admission_date { DateTime.now }
    photo_url      { 'http://www.photo.com.br' }

    trait :with_medicament_managements do
      after(:build) do |p, _evaluator|
        create_list(:medicament_management, 2, patient: p)
      end
    end
  end
end
