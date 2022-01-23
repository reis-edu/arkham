# frozen_string_literal: true

FactoryBot.define do
  factory :visitor do
    name { 'MyString' }
    username { 'MyString' }
    email { 'MyString@google.com' }
    password { 'MyString@123' }
  end
end
