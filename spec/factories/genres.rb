FactoryBot.define do
  factory :genre do
    sequence(:name) { |n| "ジャンル#{n}" }
    description { "テスト用のジャンル説明" }
  end
end