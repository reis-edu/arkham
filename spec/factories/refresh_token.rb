# frozen_string_literal: true

FactoryBot.define do
  factory :refresh_token_record, class: 'RefreshToken' do
    association :user
    sequence(:token_digest) { |n| "token-digest-#{n}" }
    expires_at { 30.days.from_now }
    revoked_at { nil }
  end
end
