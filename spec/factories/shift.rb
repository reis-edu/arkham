FactoryBot.define do
  factory :shift do
    sequence(:shift_date) { |n| Date.new(2026, 1, 1) + n.days }
    shift_type { 'diurno' }
    status { 'open' }

    trait :execution_finalized do
      status { 'execution_finalized' }
      execution_finalized_at { Time.current }
      association :execution_finalized_by, factory: :user
    end

    trait :review_finalized do
      status { 'review_finalized' }
      execution_finalized_at { Time.current }
      review_finalized_at { Time.current }
      association :execution_finalized_by, factory: :user
      association :review_finalized_by, factory: :user
    end
  end
end
