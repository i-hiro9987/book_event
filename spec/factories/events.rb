FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "テストイベント#{n}"}
    description {"テストイベントの説明文です"}
    location {"東京都渋谷区"}
    capacity {20}
    start_at {1.week.from_now}
    end_at {1.week.from_now + 2.hours}
    image_url {"https://via.placeholder.com/600x400"}

    association :book
    association :user

    trait :full do
      after(:create) do |event|
        create_list(:participation, event.capacity, event: event)
      end
    end

    trait :past do
      start_at {1.week.ago}
      end_at {1.week.ago + 2.hours}
    end

    trait :tomorrow do 
      start_at {1.day.from_now.change(hour: 19, min: 0)}
      end_at {1.day.from_now.change(hour: 21, min: 0)}
    end

  end
end