FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "テストユーザ#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    provider {"github"}
    sequence(:uid) { |n| "github_uid_#{n}"}
  end
end