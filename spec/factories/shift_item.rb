FactoryBot.define do
  factory :shift_item do
    sequence(:name) { |n| "Item de plantão #{n}" }
    description { 'Descrição do item' }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
