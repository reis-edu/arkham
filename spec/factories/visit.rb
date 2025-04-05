FactoryBot.define do
  factory :visit do
    patient_id { SecureRandom.uuid }
    visitor_id { SecureRandom.uuid }
    start_date { Time.zone.now }
    end_date { Time.zone.now + 40.minutes }
    description { 'My description' }
  end
end
