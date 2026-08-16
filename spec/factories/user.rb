# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "usuario#{n}.teste#{n}" }
    name     { 'Usuario Teste' }
    email    { 'usuario@example.com' }
    password { 'Senha@123' }
    group    { 'nursing_team' }
    active   { true }

    trait :administrator do
      group { 'administrator' }
    end

    trait :maintainer do
      group { 'maintainer' }
    end

    trait :inactive do
      active { false }
    end
  end
end
