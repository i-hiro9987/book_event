FactoryBot.define do
  factory :participation do
    comment {"楽しみにしています！"}

    association :event
    association :user

    trait :without_comment do
      comment {nil}
    end
  end
end