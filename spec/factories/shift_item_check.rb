FactoryBot.define do
  factory :shift_item_check do
    association :shift
    association :shift_item
    checked { false }
    impossible { false }
    review_status { 'pending' }

    trait :checked do
      checked { true }
      checked_at { Time.current }
      association :checked_by, factory: :user
    end

    trait :divergent do
      review_status { 'divergent' }
      divergence_note { 'Divergência encontrada' }
      reviewed_at { Time.current }
      association :reviewed_by, factory: :user
    end
  end
end
