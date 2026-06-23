FactoryBot.define do
  factory :user do
    sequence(:username) { |number| "テストユーザー#{number}" }
    sequence(:account_id) { |number| "test_user_#{number}" }
    sequence(:email) { |number| "user#{number}@example.com" }
    password { "password123" }
  end
end
