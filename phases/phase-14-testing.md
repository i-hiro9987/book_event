# Phase testing: テスト（7章）

**所要時間**: 60分  
**難易度**: ⭐⭐⭐⭐  

[← 目次に戻る](../README.md) | [← Phase concern](phase-13-concern.md)

---


### 📚 学習ポイント
- RSpecの設定
- factory_botでテストデータ作成
- Model spec（単体テスト）
- Controller spec（機能テスト）
- System spec（統合テスト）

### Task 14-1: RSpec & factory_bot導入

`Gemfile`のtest groupを更新（すでにphase-01で基本的なgemは追加済み）:

追加で必要なgemのみ追加:

```ruby
group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 5.0'
end
```

※ `debug`, `rspec-rails`, `factory_bot_rails`, `faker` はphase-01で既に追加済み

```bash
docker compose exec web bundle install
```

### Task 14-2: RSpec初期化

```bash
docker compose exec web rails generate rspec:install
```

生成されるファイル:
- `.rspec`
- `spec/spec_helper.rb`
- `spec/rails_helper.rb`

### Task 14-3: RSpec設定

`spec/rails_helper.rb`を編集:

```ruby
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# FactoryBot設定
require 'factory_bot_rails'

# Shoulda Matchers設定
require 'shoulda/matchers'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  
  # FactoryBot設定
  config.include FactoryBot::Syntax::Methods
  
  # Devise helpers（後で認証機能追加時に使用）
  # config.include Devise::Test::ControllerHelpers, type: :controller
  # config.include Devise::Test::IntegrationHelpers, type: :request
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

`.rspec`を編集:

```
--require spec_helper
--format documentation
--color
```

### Task 14-4: FactoryBot設定

`spec/factories/users.rb`を作成:

```ruby
FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "テストユーザー#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    provider { "github" }
    sequence(:uid) { |n| "github_uid_#{n}" }
  end
end
```

`spec/factories/genres.rb`を作成:

```ruby
FactoryBot.define do
  factory :genre do
    sequence(:name) { |n| "ジャンル#{n}" }
    description { "テスト用のジャンル説明" }
  end
end
```

`spec/factories/books.rb`を作成:

```ruby
FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "テスト書籍#{n}" }
    sequence(:isbn) { |n| sprintf("%013d", 9780000000000 + n) }
    author_name { "テスト著者" }
    publisher { "テスト出版社" }
    price { 3000 }
    stock { 10 }
    status { :available }
    page_count { 300 }
    
    association :user
    
    trait :sold_out do
      status { :sold_out }
      stock { 0 }
    end
    
    trait :discontinued do
      status { :discontinued }
    end
    
    trait :expensive do
      price { 5000 }
    end
  end
end
```

`spec/factories/events.rb`を作成:

```ruby
FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "テストイベント#{n}" }
    description { "テストイベントの説明文です。" }
    location { "東京都渋谷区" }
    capacity { 20 }
    start_at { 1.week.from_now }
    end_at { 1.week.from_now + 2.hours }
    image_url { "https://via.placeholder.com/600x400" }
    
    association :book
    association :user
    
    trait :full do
      after(:create) do |event|
        create_list(:participation, event.capacity, event: event)
      end
    end
    
    trait :past do
      start_at { 1.week.ago }
      end_at { 1.week.ago + 2.hours }
    end
    
    trait :tomorrow do
      start_at { 1.day.from_now.change(hour: 19, min: 0) }
      end_at { 1.day.from_now.change(hour: 21, min: 0) }
    end
  end
end
```

`spec/factories/participations.rb`を作成:

```ruby
FactoryBot.define do
  factory :participation do
    comment { "楽しみにしています！" }
    
    association :event
    association :user
    
    trait :without_comment do
      comment { nil }
    end
  end
end
```

### Task 14-5: Model spec作成

`spec/models/book_spec.rb`を作成:

```ruby
require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'バリデーション' do
    it 'valid factory' do
      book = build(:book)
      expect(book).to be_valid
    end
    
    it 'タイトルが必須' do
      book = build(:book, title: nil)
      expect(book).not_to be_valid
      expect(book.errors[:title]).to include("can't be blank")
    end
    
    it 'ISBNが必須' do
      book = build(:book, isbn: nil)
      expect(book).not_to be_valid
    end
    
    it 'ISBNは13桁の数字' do
      book = build(:book, isbn: '123')
      expect(book).not_to be_valid
      expect(book.errors[:isbn]).to include("は13桁の数字で入力してください")
    end
    
    it 'ISBNは一意' do
      create(:book, isbn: '9781234567890')
      book = build(:book, isbn: '9781234567890')
      expect(book).not_to be_valid
    end
    
    it '在庫は0以上の整数' do
      book = build(:book, stock: -1)
      expect(book).not_to be_valid
    end
  end
  
  describe 'リレーション' do
    it { should belong_to(:user) }
    it { should have_many(:book_genres).dependent(:destroy) }
    it { should have_many(:genres).through(:book_genres) }
    it { should have_many(:events).dependent(:destroy) }
  end
  
  describe 'Enum' do
    it { should define_enum_for(:status).with_values(available: 0, sold_out: 1, discontinued: 2) }
    
    it 'available?が動作する' do
      book = create(:book, status: :available)
      expect(book.available?).to be true
    end
    
    it 'sold_out!で状態を変更できる' do
      book = create(:book, status: :available)
      book.sold_out!
      expect(book.sold_out?).to be true
    end
  end
  
  describe 'scope' do
    let!(:available_book) { create(:book, status: :available) }
    let!(:sold_out_book) { create(:book, :sold_out) }
    let!(:expensive_book) { create(:book, :expensive) }
    
    it 'available_booksは販売中の書籍のみ' do
      expect(Book.available_books).to include(available_book)
      expect(Book.available_books).not_to include(sold_out_book)
    end
    
    it 'expensiveは3000円以上の書籍' do
      expect(Book.expensive).to include(expensive_book)
    end
  end
  
  describe 'コールバック' do
    it 'ISBNの正規化（数字以外を削除）' do
      book = create(:book, isbn: '978-1-234-56789-0')
      expect(book.isbn).to eq('9781234567890')
    end
  end
  
  describe 'カスタムバリデーション' do
    it '売り切れの場合、在庫は0でなければならない' do
      book = build(:book, status: :sold_out, stock: 5)
      expect(book).not_to be_valid
      expect(book.errors[:stock]).to include("は売り切れのため0にする必要があります")
    end
  end
  
  describe 'Searchable concern' do
    let!(:rails_book) { create(:book, title: 'パーフェクトRails') }
    let!(:ruby_book) { create(:book, title: 'Ruby入門', author_name: 'Rubyist') }
    
    it 'タイトルで検索できる' do
      results = Book.search_by_keyword('Rails')
      expect(results).to include(rails_book)
      expect(results).not_to include(ruby_book)
    end
    
    it '著者名で検索できる' do
      results = Book.search_by_keyword('Rubyist')
      expect(results).to include(ruby_book)
    end
  end
end
```

`spec/models/event_spec.rb`を作成:

```ruby
require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'バリデーション' do
    it 'valid factory' do
      event = build(:event)
      expect(event).to be_valid
    end
    
    it '終了時刻は開始時刻より後' do
      event = build(:event, start_at: Time.current, end_at: 1.hour.ago)
      expect(event).not_to be_valid
      expect(event.errors[:end_at]).to include("は開始時刻より後に設定してください")
    end
    
    it '定員は1以上' do
      event = build(:event, capacity: 0)
      expect(event).not_to be_valid
    end
  end
  
  describe 'リレーション' do
    it { should belong_to(:book) }
    it { should belong_to(:user) }
    it { should have_many(:participations).dependent(:destroy) }
    it { should have_many(:participants).through(:participations) }
  end
  
  describe '#full?' do
    it '定員に達している場合true' do
      event = create(:event, :full)
      expect(event.full?).to be true
    end
    
    it '定員に達していない場合false' do
      event = create(:event, capacity: 10)
      create_list(:participation, 5, event: event)
      expect(event.full?).to be false
    end
  end
  
  describe '#available_seats' do
    it '残り席数を返す' do
      event = create(:event, capacity: 10)
      create_list(:participation, 3, event: event)
      expect(event.available_seats).to eq(7)
    end
  end
  
  describe '#participated_by?' do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    
    it '参加している場合true' do
      create(:participation, event: event, user: user)
      expect(event.participated_by?(user)).to be true
    end
    
    it '参加していない場合false' do
      expect(event.participated_by?(user)).to be false
    end
  end
end
```

### Task 14-6: Controller spec作成

`spec/controllers/books_controller_spec.rb`を作成:

```ruby
require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let(:user) { create(:user) }
  let(:book) { create(:book, user: user) }
  
  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    
    it '@booksに書籍一覧が格納される' do
      book1 = create(:book)
      book2 = create(:book)
      get :index
      expect(assigns(:books)).to match_array([book1, book2])
    end
    
    it 'キーワード検索が動作する' do
      rails_book = create(:book, title: 'Rails本')
      ruby_book = create(:book, title: 'Ruby本')
      get :index, params: { keyword: 'Rails' }
      expect(assigns(:books)).to include(rails_book)
      expect(assigns(:books)).not_to include(ruby_book)
    end
  end
  
  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: book.id }
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'GET #new' do
    context 'ログインしている場合' do
      before { allow(controller).to receive(:current_user).and_return(user) }
      
      it 'returns http success' do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'ログインしていない場合' do
      before { allow(controller).to receive(:current_user).and_return(nil) }
      
      it 'リダイレクトされる' do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
```

### Task 14-7: System spec作成

`spec/system/books_spec.rb`を作成:

```ruby
require 'rails_helper'

RSpec.describe "Books", type: :system do
  let(:user) { create(:user) }
  
  before do
    driven_by(:rack_test)
  end
  
  describe '書籍一覧' do
    it '書籍が表示される' do
      book = create(:book, title: 'テスト書籍')
      visit books_path
      
      expect(page).to have_content('テスト書籍')
    end
    
    it '書籍を検索できる' do
      rails_book = create(:book, title: 'Rails本')
      ruby_book = create(:book, title: 'Ruby本')
      
      visit books_path
      fill_in 'keyword', with: 'Rails'
      click_button '🔍 検索'
      
      expect(page).to have_content('Rails本')
      expect(page).not_to have_content('Ruby本')
    end
  end
  
  describe '書籍詳細' do
    it '書籍の詳細情報が表示される' do
      book = create(:book, title: 'テスト書籍', author_name: 'テスト著者')
      visit book_path(book)
      
      expect(page).to have_content('テスト書籍')
      expect(page).to have_content('テスト著者')
    end
  end
end
```

### Task 14-8: テスト実行

```bash
# テストデータベース準備
docker compose exec web rails db:create RAILS_ENV=test
docker compose exec web rails db:migrate RAILS_ENV=test

# 全テスト実行
docker compose exec web bundle exec rspec

# 特定のファイルのみ実行
docker compose exec web bundle exec rspec spec/models/book_spec.rb

# 特定の行のみ実行
docker compose exec web bundle exec rspec spec/models/book_spec.rb:10
```

✅ **確認ポイント**:
1. すべてのテストがパスする
2. カバレッジが確認できる

```bash
git add .
git commit -m "Add RSpec tests with factory_bot"
```

---

## 🎉 完成！

おめでとうございます！EventHubプロジェクトが完成しました。

### 📊 学習達成度

✅ **Phase 0**: 環境準備
✅ **Phase 1**: Docker環境構築（10章）
✅ **Phase 2**: 基本モデル構築（1章、2章）
✅ **Phase 3**: BooksController & Views（2章）
✅ **Phase 4**: Rackミドルウェア（3-2）
✅ **Phase 5**: DB管理（3-3）
✅ **Phase 6**: 秘密情報管理（3-4）
✅ **Phase 7**: Event & Participation モデル（6章準備）
✅ **Phase 8**: GitHub OAuth認証（6章）
✅ **Phase 9**: イベント管理機能（6章）
✅ **Phase 10**: Active Job（5章 5-1）
✅ **Phase 11**: Action Mailer（5章 5-3）
✅ **Phase 12**: 検索・ページネーション（6章）
✅ **Phase 13**: Concern（13章 13-1）
✅ **Phase 14**: テスト（7章）

**完成度: 100%** 🎯

---

## 🚀 発展課題

さらなる学習のために、以下の機能を追加してみましょう：

### 1. イベントへのコメント機能
- Commentモデル作成
- ネストしたリソース
- Ajax対応

### 2. ユーザープロフィールページ
- 参加予定イベント一覧
- 登録した書籍一覧
- 開催したイベント一覧

### 3. 画像アップロード（Active Storage）
- イベント画像
- 書籍表紙画像

### 4. 通知機能
- イベント更新通知
- 新規参加者通知

### 5. API化
- JSON API（jbuilder）
- Swagger documentation

### 6. 管理画面
- ActiveAdmin導入
- ユーザー管理
- イベント承認機能

### 7. パフォーマンス最適化
- N+1クエリ解消
- bullet gem導入
- キャッシング

### 8. セキュリティ強化
- Brakeman導入
- RuboCop導入

---

## 📚 振り返り

このハンズオンで学んだこと:

1. **Dockerでの開発環境構築** - 本番に近い環境で開発
2. **MVCアーキテクチャの理解** - Railsの基本構造
3. **リレーションの実装** - 1対多、多対多
4. **バリデーションとビジネスロジック** - モデルの責務
5. **Rackミドルウェア** - Railsの内部構造
6. **マイグレーション管理** - DBスキーマのバージョン管理
7. **秘密情報管理** - credentials.yml.enc
8. **OAuth認証** - GitHubログイン
9. **非同期処理** - Active Job + Sidekiq
10. **メール送信** - Action Mailer
11. **検索とページネーション** - Kaminari
12. **コードの再利用** - Concern
13. **テスト駆動開発** - RSpec + factory_bot

---

## 📖 次のステップ

1. **書籍を最後まで読む**
   - 4章: フロントエンド開発
   - 8章: アプリケーション拡張
   - 9章: コード品質向上
   - 11-12章: 複雑なドメイン表現

2. **実際にデプロイしてみる**
   - Heroku
   - AWS（EC2, RDS）
   - Render

3. **他のRailsアプリを作ってみる**
   - ブログ
   - SNS
   - ECサイト

---

お疲れ様でした！🎊

---

## ✅ Phase testing 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

おめでとうございます！全フェーズが完了しました！🎉

[← 目次に戻る](../README.md) | [← Phase concern](phase-13-concern.md)
