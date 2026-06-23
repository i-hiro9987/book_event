FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "テスト書籍#{n}" }
    sequence(:isbn) { |n| sprintf("%013d", 9780000000000 + n)}
    author_name {"テスト著者"}
    publisher {"テスト出版社"}
    price {3000}
    stock {10}
    status {:available}
    page_count {300} 

    association :user

    trait :sold_out do
      status {:sold_out}
      stock {0}
    end

    trait :discontinued do
      status { :discontinued }
    end

    trait :expensive do
      price { 5000 }
    end

  end
end