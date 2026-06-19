# 📚 EventHub - 技術書イベント管理プラットフォーム

## 🎯 このハンズオンで学べること

このハンズオンは「パーフェクト Ruby on Rails［増補改訂版］」の以下の章を**1つの実践的なプロジェクト**で網羅します：

- **1章**: Rails環境構築、scaffold、migration、MVC基礎
- **2章**: Model（リレーション、バリデーション、scope、Enum、コールバック）、Controller、View
- **3章 3-2**: Rackミドルウェア
- **3章 3-3**: DB管理（migration、seeds）
- **3章 3-4**: credentials（秘密情報管理）
- **5章 5-1**: Active Job（非同期処理）
- **5章 5-3**: Action Mailer（メール送信）
- **6章**: 実践的Webアプリ開発（GitHub OAuth、検索、ページネーション）
- **7章**: テスト（RSpec、factory_bot、System test）
- **10章 10-1〜10-3**: Docker開発環境
- **13章 13-1**: Concern（共通機能のモジュール化）

---

## 📖 プロジェクト概要

### EventHubとは？

技術書の著者と読者をつなぐイベントプラットフォームです。

**主な機能**:
- 📚 技術書の管理（ジャンル分類、在庫管理）
- 🎉 イベント作成・管理（サイン会、勉強会など）
- 👥 GitHubアカウントでログイン
- ✉️ イベント参加時の自動メール通知
- ⏰ イベント前日の自動リマインダー
- 🔍 書籍・イベント検索機能

---

## 🏗️ データモデル設計

```
User (ユーザー)
├─ id: integer
├─ name: string
├─ email: string
├─ provider: string (GitHub)
├─ uid: string (GitHub ID)
└─ created_at: datetime

Book (技術書)
├─ id: integer
├─ title: string
├─ isbn: string (13桁)
├─ author_name: string
├─ publisher: string
├─ price: decimal
├─ stock: integer
├─ status: integer (enum: available=0, sold_out=1, discontinued=2)
├─ user_id: integer (登録者)
└─ created_at: datetime

Genre (ジャンル)
├─ id: integer
├─ name: string
└─ description: text

BookGenre (中間テーブル)
├─ id: integer
├─ book_id: integer
└─ genre_id: integer

Event (イベント)
├─ id: integer
├─ name: string (max: 50)
├─ description: text (max: 2000)
├─ location: string (max: 100)
├─ capacity: integer (定員)
├─ start_at: datetime
├─ end_at: datetime
├─ image_url: string
├─ book_id: integer (関連書籍)
├─ user_id: integer (主催者)
└─ created_at: datetime

Participation (イベント参加)
├─ id: integer
├─ event_id: integer
├─ user_id: integer
├─ comment: string (max: 30)
└─ created_at: datetime
```

**リレーション**:
- User `has_many` Books (登録した書籍)
- User `has_many` Events (作成したイベント)
- User `has_many` Participations (参加したイベント)
- Book `belongs_to` User
- Book `has_many` BookGenres
- Book `has_many` Genres `through` BookGenres
- Book `has_many` Events
- Event `belongs_to` Book
- Event `belongs_to` User
- Event `has_many` Participations
- Participation `belongs_to` Event
- Participation `belongs_to` User

---

## 🐳 Docker環境構成

```yaml
services:
  db (MySQL 8.0)
  redis (Redis 7)
  web (Rails 7)
  sidekiq (非同期ジョブ処理)
```

---

## 📋 実装タスク一覧（目次）

### [Phase 0: 環境準備](#phase-0-環境準備)
- [ ] Docker / Docker Composeインストール確認
- [ ] プロジェクトディレクトリ作成

### [Phase 1: Docker環境構築 (10章)](#phase-1-docker環境構築10章-10-1103)
- [ ] Dockerfile作成
- [ ] docker-compose.yml作成
- [ ] Rails新規プロジェクト作成
- [ ] MySQL接続確認

### [Phase 2: 基本モデル構築 (1章、2章)](#phase-2-基本モデル構築1章2章)
- [ ] User scaffoldで基本CRUD体験
- [ ] Book modelの詳細実装（バリデーション、scope、Enum、コールバック）
- [ ] Genre & BookGenre（多対多リレーション）

### [Phase 3: BooksController & Views作成 (2章)](#phase-3-bookscontroller--views作成2章)
- [ ] BooksController生成
- [ ] Books Views作成
- [ ] BooksHelper作成

### [Phase 4: Rackミドルウェア (3-2)](#phase-4-rackミドルウェア3章-3-2)
- [ ] RequestTimerミドルウェア実装

### [Phase 5: DB管理 (3-3)](#phase-5-db管理3章-3-3)
- [ ] migration練習（カラム追加、rollback）
- [ ] seeds.rb作成
- [ ] マスターデータ投入

### [Phase 6: 秘密情報管理 (3-4)](#phase-6-秘密情報管理3章-3-4)
- [ ] credentials設定
- [ ] GitHub OAuth key管理

### [Phase 7: Event & Participation モデル (6章準備)](#phase-7-event--participation-モデル6章準備)
- [ ] Event model作成
- [ ] Participation model作成

### [Phase 8: GitHub OAuth認証 (6章)](#phase-8-github-oauth認証6章-6-3)
- [ ] OmniAuth設定
- [ ] GitHub OAuth認証実装
- [ ] ログイン/ログアウト機能

### [Phase 9: イベント管理機能 (6章)](#phase-9-イベント管理機能6章)
- [ ] Event model & controller
- [ ] Participation model
- [ ] イベントCRUD、参加/キャンセル機能

### [Phase 10: Active Job (5-1)](#phase-10-active-job5章-5-1)
- [ ] Sidekiq設定
- [ ] EventReminderJob実装

### [Phase 11: Action Mailer (5-3)](#phase-11-action-mailer5章-5-3)
- [ ] ParticipationMailer実装
- [ ] EventReminderMailer実装

### [Phase 12: 検索・ページネーション (6章)](#phase-12-検索ページネーション6章)
- [ ] Kaminari導入
- [ ] 検索機能実装

### [Phase 13: Concern (13-1)](#phase-13-concern13章-13-1)
- [ ] Searchable concern
- [ ] Timestampable concern

### [Phase 14: テスト (7章)](#phase-14-テスト7章)
- [ ] RSpec, factory_bot設定
- [ ] Model spec
- [ ] Controller spec
- [ ] System spec

---

# 🚀 ハンズオン開始

---

## Phase 0: 環境準備

### Task 0-1: 必要なツールの確認

```bash
# Dockerバージョン確認
docker --version
# Docker version 20.10 以上

# Docker Composeバージョン確認
docker compose version
# Docker Compose version v2.0 以上

# Gitバージョン確認
git --version
```

✅ **確認ポイント**:
- Docker Desktop がインストールされていること
- Docker が起動していること

### Task 0-2: プロジェクトディレクトリ作成

```bash
cd ~/Documents/Books/PerfectRoR/hands-on
mkdir event_hub
cd event_hub
```

---

## Phase 1: Docker環境構築（10章 10-1〜10-3）

### 📚 学習ポイント
- Dockerの基礎
- docker-compose.ymlの構成
- Railsコンテナの構築
- MySQLコンテナとの連携

### Task 1-1: Dockerfile作成

`Dockerfile`を作成:

```dockerfile
FROM ruby:3.1.4

# 必要なパッケージのインストール
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libmariadb-dev \
  nodejs \
  yarn \
  vim \
  && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリ設定
WORKDIR /app

# Gemfile, Gemfile.lockをコピー（キャッシュ活用）
COPY Gemfile Gemfile.lock ./

# bundle install
RUN bundle install

# アプリケーションファイルをコピー
COPY . .

# エントリーポイントスクリプトのコピー
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
```

✅ **ポイント**:
- `FROM ruby:3.1.4`: Ruby 3.1.4のDockerイメージを使用
- `libmariadb-dev`: MySQL接続に必要
- `WORKDIR /app`: コンテナ内の作業ディレクトリを `/app` に設定
- Gemfileを先にコピーして`bundle install`することでDockerのレイヤーキャッシュを活用

### Task 1-2: docker-compose.yml作成

`docker-compose.yml`を作成:

```yaml
version: '3.8'

services:
  db:
    image: mysql:8.0
    platform: linux/amd64  # M1 Macの場合に必要
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: event_hub_development
      MYSQL_USER: app_user
      MYSQL_PASSWORD: app_password
    volumes:
      - mysql-data:/var/lib/mysql
    ports:
      - "3307:3306"  # ホスト側のポート3307にマッピング
    command: --default-authentication-plugin=mysql_native_password
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

  web:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0"
    volumes:
      - .:/app
      - bundle-cache:/usr/local/bundle
    ports:
      - "3000:3000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    environment:
      DATABASE_HOST: db
      DATABASE_USERNAME: app_user
      DATABASE_PASSWORD: app_password
      REDIS_URL: redis://redis:6379/1
    stdin_open: true
    tty: true

  sidekiq:
    build: .
    command: bundle exec sidekiq
    volumes:
      - .:/app
      - bundle-cache:/usr/local/bundle
    depends_on:
      - db
      - redis
    environment:
      DATABASE_HOST: db
      DATABASE_USERNAME: app_user
      DATABASE_PASSWORD: app_password
      REDIS_URL: redis://redis:6379/1

volumes:
  mysql-data:
  redis-data:
  bundle-cache:
```

✅ **ポイント**:
- **db**: MySQL 8.0を使用（書籍10章に沿う）
- **redis**: Sidekiq（Active Job）のバックエンドとして使用
- **web**: Railsアプリケーション本体
- **sidekiq**: 非同期ジョブ処理用（5章で使用）
- `platform: linux/amd64`: M1/M2 Mac対応
- `depends_on` + `healthcheck`: DBが起動してから Rails を起動
- `volumes`: データ永続化とコードのホットリロード

### Task 1-3: entrypoint.sh作成

`entrypoint.sh`を作成:

```bash
#!/bin/bash
set -e

# server.pidが残っている場合は削除
rm -f /app/tmp/pids/server.pid

# コマンドを実行
exec "$@"
```

```bash
chmod +x entrypoint.sh
```

### Task 1-4: Gemfile作成（初期版）

`Gemfile`を作成:

```ruby
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.4'

gem 'rails', '~> 7.0.8'
gem 'mysql2', '~> 0.5'
gem 'puma', '~> 5.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false

# 後で追加する gem
# gem 'omniauth-github'
# gem 'omniauth-rails_csrf_protection'
# gem 'kaminari'
# gem 'sidekiq'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # gem 'rspec-rails'
  # gem 'factory_bot_rails'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

`Gemfile.lock`を作成（空ファイル）:

```bash
touch Gemfile.lock
```

### Task 1-5: Rails新規プロジェクト作成

```bash
# Dockerイメージをビルド
docker compose build

# Railsプロジェクトを作成（既存のファイルを上書き）
docker compose run --rm web rails new . --force \
  --database=mysql \
  --skip-action-mailbox \
  --skip-action-text \
  --skip-action-cable
```

✅ **説明**:
- `--force`: 既存のGemfileを上書き
- `--database=mysql`: MySQLを使用
- `--skip-*`: 今回使わない機能をスキップ（軽量化）

### Task 1-6: database.yml設定

`config/database.yml`を編集:

```yaml
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV.fetch("DATABASE_USERNAME", "root") %>
  password: <%= ENV.fetch("DATABASE_PASSWORD", "password") %>
  host: <%= ENV.fetch("DATABASE_HOST", "localhost") %>

development:
  <<: *default
  database: event_hub_development

test:
  <<: *default
  database: event_hub_test

production:
  <<: *default
  database: event_hub_production
  username: event_hub
  password: <%= ENV['EVENT_HUB_DATABASE_PASSWORD'] %>
```

✅ **ポイント**:
- 環境変数で接続情報を管理（12 Factor App）
- `encoding: utf8mb4`: 絵文字対応

### Task 1-7: Dockerコンテナ起動とDB作成

```bash
# コンテナを起動
docker compose up -d

# ログ確認
docker compose logs -f web

# DBが起動するまで待機（healthcheckが通るまで）
# "Listening on tcp://0.0.0.0:3000" が表示されればOK

# データベース作成
docker compose exec web rails db:create

# 確認
docker compose exec web rails db:version
```

✅ **確認ポイント**:
- ブラウザで http://localhost:3000 にアクセス
- Railsのウェルカムページが表示される

### Task 1-8: Git初期化

```bash
# .gitignoreに追記（Dockerボリューム関連）
cat >> .gitignore << 'EOF'

# Docker
/vendor/bundle
EOF

# Git初期化
git init
git add .
git commit -m "Initial commit: Docker + Rails 7 + MySQL"
```

---

## Phase 2: 基本モデル構築（1章、2章）

### 📚 学習ポイント
- scaffoldでのCRUD体験（1章）
- モデルの詳細実装（2章）
  - バリデーション
  - リレーション（1対多、多対多）
  - scope
  - Enum
  - コールバック

### Task 2-1: User scaffoldで基本CRUD体験（1章）

```bash
# User scaffold生成
docker compose exec web rails generate scaffold User \
  name:string \
  email:string \
  provider:string \
  uid:string

# マイグレーション実行
docker compose exec web rails db:migrate

# ルーティング確認
docker compose exec web rails routes | grep user
```

**生成されるファイル**:
- Model: `app/models/user.rb`
- Controller: `app/controllers/users_controller.rb`
- Views: `app/views/users/`
- Migration: `db/migrate/XXXXXX_create_users.rb`
- Test: `test/models/user_test.rb`, `test/controllers/users_controller_test.rb`

✅ **動作確認**:
- http://localhost:3000/users にアクセス
- ユーザーを新規作成、編集、削除してみる

✅ **学習ポイント**:
- scaffoldで7つのRESTfulアクション（index, show, new, create, edit, update, destroy）が自動生成される
- `rails routes`でルーティングを確認
- MVC構造を体感

```bash
git add .
git commit -m "Add User scaffold"
```

### Task 2-2: Genre model作成（2章 リレーション準備）

```bash
# Genre生成
docker compose exec web rails generate model Genre \
  name:string \
  description:text

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/genre.rb`を編集:

```ruby
class Genre < ApplicationRecord
  has_many :book_genres, dependent: :destroy
  has_many :books, through: :book_genres

  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
end
```

✅ **学習ポイント**:
- `has_many :through`で多対多リレーションの準備
- バリデーション（presence, uniqueness, length）

### Task 2-3: Book model作成（2章 メイン実装）

```bash
# Book生成
docker compose exec web rails generate model Book \
  title:string \
  isbn:string \
  author_name:string \
  publisher:string \
  price:decimal \
  stock:integer \
  status:integer \
  user:references

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/book.rb`を編集:

```ruby
class Book < ApplicationRecord
  # リレーション
  belongs_to :user
  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres
  has_many :events, dependent: :destroy

  # Enum（2章 2-2-5）
  enum status: { available: 0, sold_out: 1, discontinued: 2 }

  # バリデーション（2章 2-2-3）
  validates :title, presence: true, length: { maximum: 200 }
  validates :isbn, presence: true, uniqueness: true, format: { 
    with: /\A\d{13}\z/, 
    message: "は13桁の数字で入力してください" 
  }
  validates :author_name, presence: true, length: { maximum: 100 }
  validates :publisher, length: { maximum: 100 }, allow_blank: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # カスタムバリデーション（2章 2-2-3）
  validate :stock_must_be_zero_if_sold_out

  # コールバック（2章 2-2-4）
  before_save :normalize_isbn
  after_create :log_book_creation

  # scope（2章 2-2-1）
  scope :available_books, -> { where(status: :available) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :in_stock, -> { where("stock > ?", 0) }
  scope :expensive, -> { where("price >= ?", 3000) }
  scope :recent, -> { order(created_at: :desc) }

  private

  def stock_must_be_zero_if_sold_out
    if sold_out? && stock.to_i > 0
      errors.add(:stock, "は売り切れのため0にする必要があります")
    end
  end

  def normalize_isbn
    self.isbn = isbn.gsub(/\D/, '') if isbn.present?
  end

  def log_book_creation
    Rails.logger.info "新しい書籍が登録されました: #{title} (ISBN: #{isbn})"
  end
end
```

`app/models/user.rb`に追加:

```ruby
class User < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :participations, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
```

✅ **学習ポイント**:
- **Enum**: `enum status: { available: 0, sold_out: 1, discontinued: 2 }`
  - `book.available?`, `book.sold_out!` などのメソッドが使える
- **scope**: 再利用可能なクエリ
- **コールバック**: `before_save`, `after_create`
- **カスタムバリデーション**: `validate :stock_must_be_zero_if_sold_out`

### Task 2-4: BookGenre（中間テーブル）作成

```bash
# BookGenre生成
docker compose exec web rails generate model BookGenre \
  book:references \
  genre:references

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/book_genre.rb`:

```ruby
class BookGenre < ApplicationRecord
  belongs_to :book
  belongs to :genre

  validates :book_id, uniqueness: { scope: :genre_id }
end
```

### Task 2-5: rails consoleでモデル動作確認

```bash
docker compose exec web rails c
```

```ruby
# ユーザー作成
user = User.create!(name: "山田太郎", email: "taro@example.com")

# ジャンル作成
ruby_genre = Genre.create!(name: "Ruby", description: "Ruby関連の技術書")
rails_genre = Genre.create!(name: "Rails", description: "Rails関連の技術書")

# 書籍作成
book = Book.create!(
  title: "パーフェクト Ruby on Rails",
  isbn: "9784297114237",
  author_name: "すがわらまさのり、前島真一、橋立友宏、五十嵐邦明",
  publisher: "技術評論社",
  price: 3608,
  stock: 10,
  status: :available,
  user: user
)

# ジャンル関連付け
book.book_genres.create!(genre: ruby_genre)
book.book_genres.create!(genre: rails_genre)

# リレーション確認
book.genres # => [ruby_genre, rails_genre]
ruby_genre.books # => [book]
user.books # => [book]

# Enum確認
book.available? # => true
book.sold_out! # statusが1に変わる
book.sold_out? # => true

# scope確認
Book.available_books
Book.in_stock
Book.expensive

# バリデーション確認
invalid_book = Book.new(title: "", isbn: "123") # title必須、isbn形式エラー
invalid_book.valid? # => false
invalid_book.errors.full_messages
# => ["Title can't be blank", "Isbnは13桁の数字で入力してください"]

exit
```

✅ **確認ポイント**:
- リレーションが正しく動作する
- Enumメソッド（`available?`, `sold_out!`）が使える
- scopeが動作する
- バリデーションが効く

```bash
git add .
git commit -m "Add Genre, Book, BookGenre models with validations, scopes, and callbacks"
```

---

## Phase 3: BooksController & Views作成（2章）

### 📚 学習ポイント
- Controllerの実装（RESTful、StrongParameters）
- Viewの実装（form_with、パーシャル、ヘルパー）

### Task 3-1: BooksController生成

```bash
docker compose exec web rails generate controller Books \
  index show new create edit update destroy
```

`config/routes.rb`を編集:

```ruby
Rails.application.routes.draw do
  resources :users
  resources :books
  
  root 'books#index'
end
```

### Task 3-2: BooksController実装

`app/controllers/books_controller.rb`:

```ruby
class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = Book.includes(:user, :genres).recent.page(params[:page])
  end

  def show
    # set_bookで@bookがセットされる
  end

  def new
    @book = Book.new
  end

  def create
    @book = current_user.books.new(book_params) # 後でcurrent_userを実装
    
    if @book.save
      redirect_to @book, notice: '書籍を登録しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: '書籍を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_url, notice: '書籍を削除しました'
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(
      :title, :isbn, :author_name, :publisher, :price, :stock, :status,
      genre_ids: []
    )
  end

  # 仮のcurrent_user（後でOAuth実装時に置き換え）
  def current_user
    @current_user ||= User.first || User.create!(name: "仮ユーザー", email: "temp@example.com")
  end
  helper_method :current_user
end
```

✅ **学習ポイント**:
- `before_action :set_book`: 共通処理をフィルタで実装
- `book_params`: StrongParametersでMass Assignment対策
- `genre_ids: []`: チェックボックスで複数選択を許可

### Task 3-3: ApplicationController に例外処理追加

`app/controllers/application_controller.rb`:

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render plain: "404 Not Found - お探しのページは見つかりませんでした", status: 404
  end
end
```

### Task 3-4: Books Views作成

`app/views/layouts/application.html.erb`を編集:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>EventHub</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
    
    <style>
      body { 
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        max-width: 1200px; 
        margin: 0 auto; 
        padding: 20px;
        background: #f5f5f5;
      }
      header { 
        background: white;
        border-bottom: 3px solid #2c3e50; 
        margin-bottom: 30px;
        padding: 20px;
        border-radius: 8px;
      }
      header h1 { margin: 0 0 15px 0; color: #2c3e50; }
      header h1 a { text-decoration: none; color: #2c3e50; }
      nav a { 
        margin-right: 20px; 
        text-decoration: none;
        color: #3498db;
        font-weight: 500;
      }
      nav a:hover { text-decoration: underline; }
      main { 
        background: white;
        padding: 30px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      table { width: 100%; border-collapse: collapse; margin-top: 20px; }
      th, td { 
        border: 1px solid #ddd; 
        padding: 12px 8px; 
        text-align: left; 
      }
      th { background: #34495e; color: white; }
      tr:nth-child(even) { background: #f9f9f9; }
      .notice { 
        background: #d4edda; 
        color: #155724;
        padding: 15px; 
        margin: 20px 0; 
        border-radius: 4px;
        border-left: 4px solid #28a745;
      }
      .alert {
        background: #f8d7da;
        color: #721c24;
        padding: 15px;
        margin: 20px 0;
        border-radius: 4px;
        border-left: 4px solid #dc3545;
      }
      .btn {
        display: inline-block;
        padding: 10px 20px;
        background: #3498db;
        color: white;
        text-decoration: none;
        border-radius: 4px;
        border: none;
        cursor: pointer;
      }
      .btn:hover { background: #2980b9; }
      .btn-danger { background: #e74c3c; }
      .btn-danger:hover { background: #c0392b; }
      .form-group { margin-bottom: 20px; }
      .form-group label { 
        display: block; 
        margin-bottom: 5px;
        font-weight: 500;
      }
      .form-group input[type="text"],
      .form-group input[type="number"],
      .form-group textarea,
      .form-group select {
        width: 100%;
        max-width: 500px;
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 4px;
      }
      .form-group textarea { min-height: 100px; }
      .error-messages {
        background: #f8d7da;
        color: #721c24;
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 4px;
        border-left: 4px solid #dc3545;
      }
    </style>
  </head>

  <body>
    <header>
      <h1><%= link_to '📚 EventHub - 技術書イベントプラットフォーム', root_path %></h1>
      <nav>
        <%= link_to '書籍一覧', books_path %> |
        <%= link_to 'イベント一覧', '#' %> |
        <%= link_to 'ユーザー一覧', users_path %>
      </nav>
    </header>
    
    <% if notice.present? %>
      <div class="notice"><%= notice %></div>
    <% end %>
    
    <% if alert.present? %>
      <div class="alert"><%= alert %></div>
    <% end %>
    
    <main>
      <%= yield %>
    </main>
  </body>
</html>
```

`app/views/books/index.html.erb`:

```erb
<h2>📚 書籍一覧</h2>

<%= link_to '➕ 新しい書籍を登録', new_book_path, class: 'btn' %>

<table>
  <thead>
    <tr>
      <th>タイトル</th>
      <th>著者</th>
      <th>出版社</th>
      <th>ISBN</th>
      <th>価格</th>
      <th>在庫</th>
      <th>状態</th>
      <th>ジャンル</th>
      <th>操作</th>
    </tr>
  </thead>
  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= link_to book.title, book %></td>
        <td><%= book.author_name %></td>
        <td><%= book.publisher %></td>
        <td><%= book.isbn %></td>
        <td>¥<%= number_with_delimiter(book.price) %></td>
        <td><%= book.stock %></td>
        <td><%= status_badge(book.status) %></td>
        <td><%= book.genres.map(&:name).join(', ') %></td>
        <td>
          <%= link_to '詳細', book %> |
          <%= link_to '編集', edit_book_path(book) %> |
          <%= link_to '削除', book, method: :delete, data: { confirm: '本当に削除しますか?' } %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>
```

`app/views/books/show.html.erb`:

```erb
<h2><%= @book.title %></h2>

<div style="margin: 20px 0;">
  <p><strong>著者:</strong> <%= @book.author_name %></p>
  <p><strong>出版社:</strong> <%= @book.publisher %></p>
  <p><strong>ISBN:</strong> <%= @book.isbn %></p>
  <p><strong>価格:</strong> ¥<%= number_with_delimiter(@book.price) %></p>
  <p><strong>在庫:</strong> <%= @book.stock %></p>
  <p><strong>状態:</strong> <%= status_badge(@book.status) %></p>
  
  <% if @book.genres.any? %>
    <p><strong>ジャンル:</strong> <%= @book.genres.map(&:name).join(', ') %></p>
  <% end %>
  
  <p><strong>登録者:</strong> <%= @book.user.name %></p>
  <p><strong>登録日:</strong> <%= l(@book.created_at, format: :long) %></p>
</div>

<div>
  <%= link_to '編集', edit_book_path(@book), class: 'btn' %>
  <%= link_to '削除', @book, method: :delete, data: { confirm: '本当に削除しますか?' }, class: 'btn btn-danger' %>
  <%= link_to '一覧に戻る', books_path, class: 'btn' %>
</div>
```

`app/views/books/_form.html.erb`（パーシャル）:

```erb
<%= form_with(model: book, local: true) do |form| %>
  <% if book.errors.any? %>
    <div class="error-messages">
      <h3><%= pluralize(book.errors.count, "件のエラー") %>があります:</h3>
      <ul>
        <% book.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-group">
    <%= form.label :title, 'タイトル' %>
    <%= form.text_field :title %>
  </div>

  <div class="form-group">
    <%= form.label :isbn, 'ISBN（13桁）' %>
    <%= form.text_field :isbn, placeholder: '9784297114237' %>
  </div>

  <div class="form-group">
    <%= form.label :author_name, '著者' %>
    <%= form.text_field :author_name %>
  </div>

  <div class="form-group">
    <%= form.label :publisher, '出版社' %>
    <%= form.text_field :publisher %>
  </div>

  <div class="form-group">
    <%= form.label :price, '価格（円）' %>
    <%= form.number_field :price, step: 0.01 %>
  </div>

  <div class="form-group">
    <%= form.label :stock, '在庫数' %>
    <%= form.number_field :stock, min: 0 %>
  </div>

  <div class="form-group">
    <%= form.label :status, '状態' %>
    <%= form.select :status, Book.statuses.keys.map { |k| [k, k] } %>
  </div>

  <div class="form-group">
    <%= form.label :genre_ids, 'ジャンル（複数選択可）' %>
    <%= form.collection_check_boxes :genre_ids, Genre.all, :id, :name do |b| %>
      <div>
        <%= b.check_box %> <%= b.label %>
      </div>
    <% end %>
  </div>

  <div class="form-group">
    <%= form.submit '保存', class: 'btn' %>
  </div>
<% end %>
```

`app/views/books/new.html.erb`:

```erb
<h2>新しい書籍を登録</h2>

<%= render 'form', book: @book %>

<%= link_to '一覧に戻る', books_path %>
```

`app/views/books/edit.html.erb`:

```erb
<h2>書籍を編集</h2>

<%= render 'form', book: @book %>

<%= link_to '詳細', @book %> |
<%= link_to '一覧に戻る', books_path %>
```

### Task 3-5: BooksHelper作成

`app/helpers/books_helper.rb`:

```ruby
module BooksHelper
  def status_badge(status)
    case status
    when "available"
      "✅ 販売中"
    when "sold_out"
      "📤 売り切れ"
    when "discontinued"
      "⛔️ 販売終了"
    else
      status
    end
  end
end
```

### Task 3-6: 日本語ロケール設定

`config/application.rb`に追加:

```ruby
module EventHub
  class Application < Rails::Application
    config.load_defaults 7.0
    
    # 追加
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
  end
end
```

`config/locales/ja.yml`を作成:

```yaml
ja:
  activerecord:
    models:
      book: 書籍
      user: ユーザー
      genre: ジャンル
    attributes:
      book:
        title: タイトル
        isbn: ISBN
        author_name: 著者
        publisher: 出版社
        price: 価格
        stock: 在庫
        status: 状態
  date:
    formats:
      long: "%Y年%m月%d日"
  time:
    formats:
      long: "%Y年%m月%d日 %H時%M分"
```

### Task 3-7: 動作確認

```bash
# サーバー再起動
docker compose restart web

# ブラウザで確認
# http://localhost:3000/books
```

✅ **確認ポイント**:
- 書籍の新規作成ができる
- ジャンルを複数選択できる
- バリデーションエラーが表示される
- エスケープ処理を確認（titleに`<script>alert('XSS')</script>`を入力して、実行されないことを確認）

```bash
git add .
git commit -m "Add Books controller and views with helpers"
```

---

## Phase 4: Rackミドルウェア（3章 3-2）

### 📚 学習ポイント
- Rackミドルウェアの仕組み
- `call(env)`メソッド
- Railsへの組み込み

### Task 4-1: RequestTimerミドルウェア作成

`lib/middleware/request_timer.rb`を作成:

```ruby
module Middleware
  class RequestTimer
    def initialize(app)
      @app = app
    end

    def call(env)
      start_time = Time.now
      request_method = env["REQUEST_METHOD"]
      request_path = env["PATH_INFO"]
      
      # 次のミドルウェア/アプリケーションを呼び出し
      status, headers, response = @app.call(env)
      
      # 処理時間を計算
      elapsed_time = ((Time.now - start_time) * 1000).round(2)
      
      # ログ出力
      Rails.logger.info "[RequestTimer] #{request_method} #{request_path} - #{elapsed_time}ms"
      
      # レスポンスを返す
      [status, headers, response]
    end
  end
end
```

### Task 4-2: Railsに組み込み

`config/application.rb`を編集:

```ruby
require_relative "boot"

require "rails/all"

# 追加
require_relative '../lib/middleware/request_timer'

Bundler.require(*Rails.groups)

module EventHub
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
    
    # 追加
    config.middleware.use Middleware::RequestTimer
  end
end
```

### Task 4-3: ミドルウェア確認

```bash
# ミドルウェアスタック確認
docker compose exec web rails middleware

# 出力に "use Middleware::RequestTimer" が含まれることを確認
```

### Task 4-4: 動作確認

```bash
# サーバー再起動
docker compose restart web

# ブラウザでページにアクセス
# http://localhost:3000/books

# ログ確認
docker compose logs -f web

# 出力例:
# [RequestTimer] GET /books - 45.23ms
# [RequestTimer] GET /assets/application.css - 12.34ms
```

✅ **学習ポイント**:
- Rackミドルウェアは`call(env)`を実装するオブジェクト
- `env`はHTTPリクエストの情報を含むHash
- `@app.call(env)`で次のミドルウェアを呼び出し
- レスポンスは`[status, headers, body]`の配列

```bash
git add .
git commit -m "Add RequestTimer Rack middleware"
```

---

## Phase 5: DB管理（3章 3-3）

### 📚 学習ポイント
- migration（カラム追加、rollback）
- seeds.rb（マスターデータ投入）
- db:migrate:status

### Task 5-1: カラム追加migration

```bash
# ページ数カラムを追加
docker compose exec web rails generate migration AddPageCountToBooks page_count:integer

# 生成されたファイルを確認
# db/migrate/XXXXXX_add_page_count_to_books.rb
```

生成されたマイグレーションファイル:

```ruby
class AddPageCountToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :page_count, :integer
  end
end
```

### Task 5-2: migration実行と確認

```bash
# migration状態確認
docker compose exec web rails db:migrate:status

# migration実行
docker compose exec web rails db:migrate

# 再度状態確認
docker compose exec web rails db:migrate:status
# "up" になっていることを確認
```

### Task 5-3: rollback練習

```bash
# 1つ戻す
docker compose exec web rails db:rollback

# 状態確認
docker compose exec web rails db:migrate:status
# 最新のmigrationが "down" になっていることを確認

# 再度実行して戻す
docker compose exec web rails db:migrate
```

### Task 5-4: カラムデフォルト値変更migration

```bash
docker compose exec web rails generate migration ChangeStockDefaultInBooks
```

生成されたファイルを編集:

```ruby
class ChangeStockDefaultInBooks < ActiveRecord::Migration[7.0]
  def up
    change_column_default :books, :stock, from: nil, to: 0
  end

  def down
    change_column_default :books, :stock, from: 0, to: nil
  end
end
```

```bash
docker compose exec web rails db:migrate
```

✅ **学習ポイント**:
- `up`/`down`で可逆性を保証
- `change`メソッドは自動で可逆性を判断

### Task 5-5: seeds.rb作成

`db/seeds.rb`を編集:

```ruby
# ユーザー作成
puts "Creating users..."
users = [
  { name: '山田太郎', email: 'taro@example.com' },
  { name: '佐藤花子', email: 'hanako@example.com' },
  { name: '鈴木一郎', email: 'ichiro@example.com' }
]

users.each do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.name = user_data[:name]
  end
end

puts "#{User.count} users created"

# ジャンル作成
puts "Creating genres..."
genres_data = [
  { name: 'Ruby', description: 'Ruby言語の技術書' },
  { name: 'Rails', description: 'Ruby on Railsの技術書' },
  { name: 'JavaScript', description: 'JavaScript関連の技術書' },
  { name: 'Python', description: 'Python関連の技術書' },
  { name: 'データベース', description: 'DB設計・SQL関連' },
  { name: 'インフラ', description: 'Docker・AWS等' }
]

genres_data.each do |genre_data|
  Genre.find_or_create_by!(name: genre_data[:name]) do |genre|
    genre.description = genre_data[:description]
  end
end

puts "#{Genre.count} genres created"

# 書籍作成
puts "Creating books..."
ruby_genre = Genre.find_by(name: 'Ruby')
rails_genre = Genre.find_by(name: 'Rails')
js_genre = Genre.find_by(name: 'JavaScript')
db_genre = Genre.find_by(name: 'データベース')
infra_genre = Genre.find_by(name: 'インフラ')

user1 = User.first
user2 = User.second

books_data = [
  {
    title: 'パーフェクト Ruby on Rails［増補改訂版］',
    isbn: '9784297114237',
    author_name: 'すがわらまさのり、前島真一、橋立友宏、五十嵐邦明',
    publisher: '技術評論社',
    price: 3608,
    stock: 15,
    page_count: 456,
    status: :available,
    user: user1,
    genres: [ruby_genre, rails_genre]
  },
  {
    title: 'プロを目指す人のためのRuby入門',
    isbn: '9784297124373',
    author_name: '伊藤淳一',
    publisher: '技術評論社',
    price: 3278,
    stock: 20,
    page_count: 512,
    status: :available,
    user: user1,
    genres: [ruby_genre]
  },
  {
    title: 'JavaScript本格入門',
    isbn: '9784297137663',
    author_name: '山田祥寛',
    publisher: '技術評論社',
    price: 3080,
    stock: 10,
    page_count: 624,
    status: :available,
    user: user2,
    genres: [js_genre]
  },
  {
    title: 'SQL実践入門',
    isbn: '9784774187013',
    author_name: 'ミック',
    publisher: '技術評論社',
    price: 2750,
    stock: 8,
    page_count: 304,
    status: :available,
    user: user2,
    genres: [db_genre]
  },
  {
    title: 'Docker実践ガイド',
    isbn: '9784295013464',
    author_name: '古賀政純',
    publisher: 'インプレス',
    price: 3520,
    stock: 0,
    page_count: 368,
    status: :sold_out,
    user: user1,
    genres: [infra_genre]
  }
]

books_data.each do |book_data|
  book_genres = book_data.delete(:genres)
  
  book = Book.find_or_create_by!(isbn: book_data[:isbn]) do |b|
    b.assign_attributes(book_data)
  end
  
  book_genres.each do |genre|
    BookGenre.find_or_create_by!(book: book, genre: genre)
  end
end

puts "#{Book.count} books created"
puts "Seed data created successfully!"
```

### Task 5-6: seeds実行

```bash
# seeds実行
docker compose exec web rails db:seed

# 確認
docker compose exec web rails c
```

```ruby
User.count # => 3
Genre.count # => 6
Book.count # => 5

# リレーション確認
book = Book.find_by(isbn: '9784297114237')
book.genres.map(&:name) # => ["Ruby", "Rails"]

exit
```

### Task 5-7: データベースリセット練習

```bash
# データベース全体をリセット（drop → create → migrate → seed）
docker compose exec web rails db:reset

# 確認
# http://localhost:3000/books
# 5冊の書籍が表示される
```

✅ **学習ポイント**:
- `db:seed`: seedsを実行
- `db:reset`: drop → create → migrate → seed を一括実行
- `find_or_create_by!`: 冪等性を保証（何度実行しても同じ結果）

```bash
git add .
git commit -m "Add migrations and seeds for initial data"
```

---

## Phase 6: 秘密情報管理（3章 3-4）

### 📚 学習ポイント
- credentials.yml.encの仕組み
- `rails credentials:edit`
- `Rails.application.credentials`

### Task 6-1: credentials確認

```bash
# 現在のcredentials確認
docker compose exec web rails credentials:show
```

出力例:
```yaml
secret_key_base: xxxxx...
```

### Task 6-2: credentials編集

```bash
# エディタで編集
docker compose exec web bash -c "EDITOR='vim' rails credentials:edit"
```

viエディタで以下を追加:

```yaml
# 既存の内容
secret_key_base: xxxxx...

# 追加
event_hub:
  admin_email: admin@eventhub.example.com
  support_email: support@eventhub.example.com
  max_event_capacity: 100

# 後でGitHub OAuth設定を追加予定
# github:
#   client_id: YOUR_CLIENT_ID
#   client_secret: YOUR_CLIENT_SECRET
```

保存して終了（`:wq`）

### Task 6-3: credentialsから読み込み

`app/controllers/books_controller.rb`の`index`アクションに追加:

```ruby
def index
  # credentials確認用（開発環境のみ）
  if Rails.env.development?
    admin_email = Rails.application.credentials.event_hub[:admin_email]
    Rails.logger.info "管理者メール: #{admin_email}"
  end
  
  @books = Book.includes(:user, :genres).recent
end
```

### Task 6-4: 動作確認

```bash
# サーバー再起動
docker compose restart web

# ブラウザで http://localhost:3000/books にアクセス

# ログ確認
docker compose logs web | grep "管理者メール"
# 出力: 管理者メール: admin@eventhub.example.com
```

### Task 6-5: .gitignore確認

```bash
# master.keyが.gitignoreに含まれているか確認
cat .gitignore | grep master.key
# 出力: /config/master.key
```

✅ **重要**:
- `config/master.key`は絶対にGitにコミットしない
- `config/credentials.yml.enc`はコミットしてOK（暗号化済み）
- 本番環境では環境変数`RAILS_MASTER_KEY`でmaster.keyを渡す

```bash
git add .
git commit -m "Add credentials configuration for EventHub settings"
```

---

## Phase 7: Event & Participation モデル（6章準備）

### 📚 学習ポイント
- イベントモデルの設計
- 参加機能の実装（多対多リレーション）
- 定員管理のビジネスロジック

### Task 7-1: Event model作成

```bash
# Event生成
docker compose exec web rails generate model Event \
  name:string \
  description:text \
  location:string \
  capacity:integer \
  start_at:datetime \
  end_at:datetime \
  image_url:string \
  book:references \
  user:references

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/event.rb`:

```ruby
class Event < ApplicationRecord
  belongs_to :book
  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user

  # バリデーション（6章）
  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :location, presence: true, length: { maximum: 100 }
  validates :capacity, presence: true, numericality: { 
    only_integer: true, 
    greater_than: 0,
    less_than_or_equal_to: 1000
  }
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_at_after_start_at

  # scope（2章）
  scope :upcoming, -> { where("start_at >= ?", Time.current).order(start_at: :asc) }
  scope :past, -> { where("start_at < ?", Time.current).order(start_at: :desc) }
  scope :by_book, ->(book_id) { where(book_id: book_id) }
  scope :recent, -> { order(created_at: :desc) }

  # ビジネスロジック
  def full?
    participations.count >= capacity
  end

  def available_seats
    capacity - participations.count
  end

  def started?
    start_at <= Time.current
  end

  def finished?
    end_at <= Time.current
  end

  def ongoing?
    started? && !finished?
  end

  def participated_by?(user)
    return false unless user
    participants.include?(user)
  end

  def created_by?(user)
    return false unless user
    self.user_id == user.id
  end

  private

  def end_at_after_start_at
    return if start_at.blank? || end_at.blank?
    
    if end_at <= start_at
      errors.add(:end_at, "は開始時刻より後に設定してください")
    end
  end
end
```

`app/models/book.rb`に追加:

```ruby
# 既存のリレーションに追加
has_many :events, dependent: :destroy
```

`app/models/user.rb`に追加:

```ruby
# 既存のリレーションに追加
has_many :events, dependent: :destroy
has_many :participations, dependent: :destroy
has_many :participated_events, through: :participations, source: :event
```

✅ **学習ポイント**:
- `has_many :through`で多対多リレーション
- カスタムバリデーション: `end_at_after_start_at`
- ビジネスロジックメソッド: `full?`, `available_seats`, `participated_by?`

### Task 7-2: Participation model作成

```bash
# Participation生成
docker compose exec web rails generate model Participation \
  event:references \
  user:references \
  comment:string

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/participation.rb`:

```ruby
class Participation < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :comment, length: { maximum: 30 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :event_id, message: "は既にこのイベントに参加しています" }
  validate :event_must_not_be_full
  validate :event_must_not_be_finished

  private

  def event_must_not_be_full
    return if event.blank?
    
    if event.full?
      errors.add(:base, "このイベントは定員に達しています")
    end
  end

  def event_must_not_be_finished
    return if event.blank?
    
    if event.finished?
      errors.add(:base, "このイベントは既に終了しています")
    end
  end
end
```

✅ **学習ポイント**:
- `uniqueness: { scope: :event_id }`: 同じユーザーが同じイベントに複数回参加できない
- カスタムバリデーション: 定員チェック、終了イベントチェック

### Task 7-3: rails consoleで動作確認

```bash
docker compose exec web rails c
```

```ruby
# ユーザーと書籍取得
user = User.first
book = Book.first

# イベント作成
event = Event.create!(
  name: "パーフェクトRails 読書会",
  description: "Rails本を読んで学ぶ勉強会です",
  location: "東京都渋谷区",
  capacity: 10,
  start_at: 1.week.from_now,
  end_at: 1.week.from_now + 2.hours,
  book: book,
  user: user
)

# イベント状態確認
event.upcoming? # => true
event.full? # => false
event.available_seats # => 10

# 参加者追加
user2 = User.second
participation = Participation.create!(
  event: event,
  user: user2,
  comment: "楽しみです！"
)

# リレーション確認
event.participants # => [user2]
user2.participated_events # => [event]
event.participated_by?(user2) # => true

# 定員確認
event.available_seats # => 9

exit
```

### Task 7-4: seeds.rbにイベントデータ追加

`db/seeds.rb`の最後に追加:

```ruby
# イベント作成
puts "Creating events..."

book1 = Book.find_by(isbn: '9784297114237') # パーフェクトRails
book2 = Book.find_by(isbn: '9784297124373') # Ruby入門
user1 = User.first

events_data = [
  {
    name: 'パーフェクトRails 読書会 #1',
    description: '第1章〜第3章を読んで、Railsの基礎を学びます。初心者歓迎！',
    location: '東京都渋谷区 渋谷駅前会議室',
    capacity: 20,
    start_at: 1.week.from_now.change(hour: 19, min: 0),
    end_at: 1.week.from_now.change(hour: 21, min: 0),
    image_url: 'https://via.placeholder.com/600x400?text=Rails+Study',
    book: book1,
    user: user1
  },
  {
    name: 'Ruby初心者もくもく会',
    description: 'Rubyを学び始めた方向けのもくもく会です。質問歓迎！',
    location: 'オンライン（Zoom）',
    capacity: 30,
    start_at: 10.days.from_now.change(hour: 14, min: 0),
    end_at: 10.days.from_now.change(hour: 17, min: 0),
    image_url: 'https://via.placeholder.com/600x400?text=Ruby+Mokumoku',
    book: book2,
    user: user1
  },
  {
    name: 'パーフェクトRails 著者サイン会',
    description: '著者が来場してサイン会を開催します！',
    location: '東京都千代田区 技術評論社本社',
    capacity: 50,
    start_at: 2.weeks.from_now.change(hour: 18, min: 0),
    end_at: 2.weeks.from_now.change(hour: 20, min: 0),
    image_url: 'https://via.placeholder.com/600x400?text=Book+Signing',
    book: book1,
    user: user1
  }
]

events_data.each do |event_data|
  Event.find_or_create_by!(
    name: event_data[:name],
    start_at: event_data[:start_at]
  ) do |event|
    event.assign_attributes(event_data)
  end
end

puts "#{Event.count} events created"

# サンプル参加データ
puts "Creating participations..."
event1 = Event.first
user2 = User.second
user3 = User.third

Participation.find_or_create_by!(event: event1, user: user2) do |p|
  p.comment = "楽しみにしています！"
end

Participation.find_or_create_by!(event: event1, user: user3) do |p|
  p.comment = "初心者ですがよろしくお願いします"
end

puts "#{Participation.count} participations created"
puts "All seed data created successfully!"
```

```bash
# seeds実行
docker compose exec web rails db:seed
```

```bash
git add .
git commit -m "Add Event and Participation models with business logic"
```

---

## Phase 8: GitHub OAuth認証（6章 6-3）

### 📚 学習ポイント
- OAuthの仕組み
- OmniAuth gemの使い方
- GitHubアプリ登録
- セッション管理

### Task 8-1: Gemfile更新

`Gemfile`に追加:

```ruby
# OAuth認証
gem 'omniauth-github', '~> 2.0'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
```

```bash
docker compose exec web bundle install
docker compose restart web
```

### Task 8-2: GitHub OAuthアプリ登録

1. GitHub にアクセス: https://github.com/settings/developers
2. "OAuth Apps" → "New OAuth App"をクリック
3. 以下を入力:
   - **Application name**: EventHub (Development)
   - **Homepage URL**: http://localhost:3000
   - **Authorization callback URL**: http://localhost:3000/auth/github/callback
4. "Register application"をクリック
5. **Client ID** と **Client Secret** をコピー

### Task 8-3: credentialsにGitHub OAuth情報を保存

```bash
docker compose exec web bash -c "EDITOR='vim' rails credentials:edit"
```

```yaml
# 既存の内容はそのまま
event_hub:
  admin_email: admin@eventhub.example.com
  support_email: support@eventhub.example.com
  max_event_capacity: 100

# 追加
github:
  client_id: YOUR_GITHUB_CLIENT_ID
  client_secret: YOUR_GITHUB_CLIENT_SECRET
```

保存して終了（`:wq`）

### Task 8-4: OmniAuth設定

`config/initializers/omniauth.rb`を作成:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
    Rails.application.credentials.github[:client_id],
    Rails.application.credentials.github[:client_secret],
    scope: "user:email"
end

# CSRF対策
OmniAuth.config.allowed_request_methods = [:post, :get]
```

### Task 8-5: ルーティング設定

`config/routes.rb`を編集:

```ruby
Rails.application.routes.draw do
  resources :users
  resources :books
  
  # OAuth認証
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  delete '/logout', to: 'sessions#destroy'
  
  root 'books#index'
end
```

### Task 8-6: SessionsController作成

```bash
docker compose exec web rails generate controller Sessions create destroy failure
```

`app/controllers/sessions_controller.rb`:

```ruby
class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    
    user = User.find_or_create_by!(provider: auth['provider'], uid: auth['uid']) do |u|
      u.name = auth['info']['name'] || auth['info']['nickname']
      u.email = auth['info']['email']
    end
    
    session[:user_id] = user.id
    redirect_to root_path, notice: "#{user.name}さん、ようこそ！"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'ログアウトしました'
  end

  def failure
    redirect_to root_path, alert: '認証に失敗しました'
  end
end
```

### Task 8-7: ApplicationControllerに認証メソッド追加

`app/controllers/application_controller.rb`:

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def authenticate_user!
    unless logged_in?
      redirect_to root_path, alert: 'ログインが必要です'
    end
  end

  def record_not_found
    render plain: "404 Not Found - お探しのページは見つかりませんでした", status: 404
  end
end
```

### Task 8-8: BooksControllerを更新（仮のcurrent_userを削除）

`app/controllers/books_controller.rb`:

```ruby
class BooksController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = Book.includes(:user, :genres).recent
  end

  def show
  end

  def new
    @book = Book.new
  end

  def create
    @book = current_user.books.new(book_params)
    
    if @book.save
      redirect_to @book, notice: '書籍を登録しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: '書籍を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_url, notice: '書籍を削除しました'
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(
      :title, :isbn, :author_name, :publisher, :price, :stock, :status,
      genre_ids: []
    )
  end
end
```

### Task 8-9: レイアウトにログイン/ログアウトボタン追加

`app/views/layouts/application.html.erb`のheader部分を更新:

```erb
<header>
  <h1><%= link_to '📚 EventHub - 技術書イベントプラットフォーム', root_path %></h1>
  <nav>
    <%= link_to '書籍一覧', books_path %> |
    <%= link_to 'イベント一覧', '#' %>
    
    <span style="float: right;">
      <% if logged_in? %>
        👤 <%= current_user.name %> |
        <%= button_to 'ログアウト', logout_path, method: :delete, 
            data: { turbo: false }, 
            style: 'display: inline; background: none; border: none; color: #3498db; cursor: pointer; text-decoration: underline;' %>
      <% else %>
        <%= button_to 'GitHubでログイン', '/auth/github', method: :post, 
            data: { turbo: false },
            style: 'display: inline; background: #24292e; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;' %>
      <% end %>
    </span>
  </nav>
</header>
```

### Task 8-10: 動作確認

```bash
# サーバー再起動
docker compose restart web

# ブラウザで確認
# http://localhost:3000
```

✅ **確認ポイント**:
1. 「GitHubでログイン」ボタンをクリック
2. GitHubの認証画面が表示される
3. 認証を許可すると、EventHubにリダイレクトされる
4. ログイン状態になり、名前が表示される
5. 「ログアウト」をクリックすると、ログアウトできる

```bash
git add .
git commit -m "Add GitHub OAuth authentication"
```

---

## Phase 9: イベント管理機能（6章）

### 📚 学習ポイント
- イベントのCRUD操作
- 参加/キャンセル機能
- 複雑なビジネスロジックの実装

### Task 9-1: EventsController作成

```bash
docker compose exec web rails generate controller Events \
  index show new create edit update destroy
```

`config/routes.rb`を更新:

```ruby
Rails.application.routes.draw do
  resources :users
  resources :books
  resources :events do
    member do
      post :participate
      delete :cancel_participation
    end
  end
  
  # OAuth認証
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  delete '/logout', to: 'sessions#destroy'
  
  root 'books#index'
end
```

### Task 9-2: EventsController実装

`app/controllers/events_controller.rb`:

```ruby
class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :participate, :cancel_participation]
  before_action :check_event_owner, only: [:edit, :update, :destroy]

  def index
    @events = Event.includes(:book, :user, :participants).upcoming
  end

  def show
    @participation = @event.participations.find_by(user: current_user) if logged_in?
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.new(event_params)
    
    if @event.save
      redirect_to @event, notice: 'イベントを作成しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'イベントを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: 'イベントを削除しました'
  end

  def participate
    @participation = @event.participations.build(
      user: current_user,
      comment: params[:comment]
    )
    
    if @participation.save
      # 後でメール送信を追加
      redirect_to @event, notice: 'イベントに参加しました'
    else
      redirect_to @event, alert: @participation.errors.full_messages.join(', ')
    end
  end

  def cancel_participation
    @participation = @event.participations.find_by(user: current_user)
    
    if @participation
      @participation.destroy
      redirect_to @event, notice: '参加をキャンセルしました'
    else
      redirect_to @event, alert: 'このイベントに参加していません'
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def check_event_owner
    unless @event.created_by?(current_user)
      redirect_to @event, alert: 'このイベントを編集する権限がありません'
    end
  end

  def event_params
    params.require(:event).permit(
      :name, :description, :location, :capacity,
      :start_at, :end_at, :image_url, :book_id
    )
  end
end
```

### Task 9-3: Events Views作成

`app/views/events/index.html.erb`:

```erb
<h2>🎉 イベント一覧</h2>

<% if logged_in? %>
  <%= link_to '➕ 新しいイベントを作成', new_event_path, class: 'btn' %>
<% end %>

<% if @events.any? %>
  <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px;">
    <% @events.each do |event| %>
      <div style="border: 1px solid #ddd; border-radius: 8px; padding: 15px; background: white;">
        <% if event.image_url.present? %>
          <img src="<%= event.image_url %>" alt="<%= event.name %>" style="width: 100%; height: 150px; object-fit: cover; border-radius: 4px; margin-bottom: 10px;">
        <% end %>
        
        <h3 style="margin: 10px 0;"><%= link_to event.name, event %></h3>
        
        <p style="font-size: 14px; color: #666;">
          📖 <%= link_to event.book.title, event.book %><br>
          📍 <%= event.location %><br>
          🕐 <%= l(event.start_at, format: :long) %><br>
          👥 <%= event.participants.count %> / <%= event.capacity %> 人
        </p>
        
        <% if event.full? %>
          <span style="color: red; font-weight: bold;">🈵 満員</span>
        <% else %>
          <span style="color: green;">残り <%= event.available_seats %> 席</span>
        <% end %>
      </div>
    <% end %>
  </div>
<% else %>
  <p>現在、開催予定のイベントはありません。</p>
<% end %>
```

`app/views/events/show.html.erb`:

```erb
<h2><%= @event.name %></h2>

<% if @event.image_url.present? %>
  <img src="<%= @event.image_url %>" alt="<%= @event.name %>" style="max-width: 600px; width: 100%; border-radius: 8px; margin: 20px 0;">
<% end %>

<div style="margin: 20px 0;">
  <p><strong>📖 関連書籍:</strong> <%= link_to @event.book.title, @event.book %></p>
  <p><strong>📍 場所:</strong> <%= @event.location %></p>
  <p><strong>🕐 開始:</strong> <%= l(@event.start_at, format: :long) %></p>
  <p><strong>🕐 終了:</strong> <%= l(@event.end_at, format: :long) %></p>
  <p><strong>👥 定員:</strong> <%= @event.capacity %> 人</p>
  <p><strong>👤 主催者:</strong> <%= @event.user.name %></p>
  
  <% if @event.description.present? %>
    <div style="background: #f9f9f9; padding: 15px; border-radius: 4px; margin: 15px 0;">
      <strong>📝 詳細:</strong><br>
      <%= simple_format(@event.description) %>
    </div>
  <% end %>
</div>

<!-- 参加状況 -->
<div style="background: #e8f4f8; padding: 15px; border-radius: 4px; margin: 20px 0;">
  <h3 style="margin-top: 0;">参加状況</h3>
  <p style="font-size: 18px; font-weight: bold;">
    <%= @event.participants.count %> / <%= @event.capacity %> 人
    
    <% if @event.full? %>
      <span style="color: red;">（満員）</span>
    <% else %>
      <span style="color: green;">（残り <%= @event.available_seats %> 席）</span>
    <% end %>
  </p>
</div>

<!-- 参加ボタン -->
<% if logged_in? %>
  <div style="margin: 20px 0;">
    <% if @event.finished? %>
      <p style="color: #999;">このイベントは終了しました</p>
    <% elsif @event.created_by?(current_user) %>
      <p>あなたが主催するイベントです</p>
    <% elsif @participation %>
      <p style="color: green;">✅ 参加済み</p>
      <% if @participation.comment.present? %>
        <p style="font-style: italic; color: #666;">コメント: 「<%= @participation.comment %>」</p>
      <% end %>
      <%= button_to '参加をキャンセル', cancel_participation_event_path(@event), 
          method: :delete, 
          data: { confirm: '本当にキャンセルしますか？' },
          class: 'btn btn-danger' %>
    <% elsif @event.full? %>
      <p style="color: red;">このイベントは満員です</p>
    <% else %>
      <%= form_with url: participate_event_path(@event), method: :post, local: true do |f| %>
        <div class="form-group">
          <%= f.label :comment, 'コメント（任意、30文字まで）' %>
          <%= f.text_field :comment, placeholder: '参加の意気込みなど', maxlength: 30 %>
        </div>
        <%= f.submit 'このイベントに参加する', class: 'btn', data: { confirm: '参加しますか？' } %>
      <% end %>
    <% end %>
  </div>
<% else %>
  <p style="background: #fff3cd; padding: 15px; border-radius: 4px;">
    イベントに参加するには <%= button_to 'GitHubでログイン', '/auth/github', method: :post, 
        data: { turbo: false },
        style: 'display: inline; background: #24292e; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;' %> が必要です
  </p>
<% end %>

<!-- 参加者一覧 -->
<% if @event.participants.any? %>
  <div style="margin: 30px 0;">
    <h3>👥 参加者一覧（<%= @event.participants.count %>人）</h3>
    <ul style="list-style: none; padding: 0;">
      <% @event.participations.includes(:user).each do |participation| %>
        <li style="border-bottom: 1px solid #eee; padding: 10px 0;">
          <strong><%= participation.user.name %></strong>
          <% if participation.comment.present? %>
            <br>
            <span style="color: #666; font-size: 14px;">💬 <%= participation.comment %></span>
          <% end %>
        </li>
      <% end %>
    </ul>
  </div>
<% end %>

<!-- 編集・削除ボタン -->
<% if logged_in? && @event.created_by?(current_user) %>
  <div style="margin: 20px 0;">
    <%= link_to '編集', edit_event_path(@event), class: 'btn' %>
    <%= link_to '削除', @event, method: :delete, data: { confirm: '本当に削除しますか?' }, class: 'btn btn-danger' %>
  </div>
<% end %>

<%= link_to 'イベント一覧に戻る', events_path, class: 'btn' %>
```

`app/views/events/_form.html.erb`:

```erb
<%= form_with(model: event, local: true) do |form| %>
  <% if event.errors.any? %>
    <div class="error-messages">
      <h3><%= pluralize(event.errors.count, "件のエラー") %>があります:</h3>
      <ul>
        <% event.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-group">
    <%= form.label :name, 'イベント名' %>
    <%= form.text_field :name, placeholder: '例: パーフェクトRails 読書会', maxlength: 50 %>
  </div>

  <div class="form-group">
    <%= form.label :book_id, '関連書籍' %>
    <%= form.collection_select :book_id, Book.all, :id, :title, { prompt: '書籍を選択' } %>
  </div>

  <div class="form-group">
    <%= form.label :description, '説明' %>
    <%= form.text_area :description, rows: 5, placeholder: 'イベントの詳細を入力...', maxlength: 2000 %>
  </div>

  <div class="form-group">
    <%= form.label :location, '場所' %>
    <%= form.text_field :location, placeholder: '例: 東京都渋谷区 / オンライン（Zoom）', maxlength: 100 %>
  </div>

  <div class="form-group">
    <%= form.label :capacity, '定員' %>
    <%= form.number_field :capacity, min: 1, max: 1000, placeholder: '例: 20' %>
  </div>

  <div class="form-group">
    <%= form.label :start_at, '開始日時' %>
    <%= form.datetime_local_field :start_at %>
  </div>

  <div class="form-group">
    <%= form.label :end_at, '終了日時' %>
    <%= form.datetime_local_field :end_at %>
  </div>

  <div class="form-group">
    <%= form.label :image_url, '画像URL（任意）' %>
    <%= form.text_field :image_url, placeholder: 'https://example.com/image.jpg' %>
    <small style="color: #666;">プレースホルダー例: https://via.placeholder.com/600x400?text=Event</small>
  </div>

  <div class="form-group">
    <%= form.submit '保存', class: 'btn' %>
  </div>
<% end %>
```

`app/views/events/new.html.erb`:

```erb
<h2>新しいイベントを作成</h2>

<%= render 'form', event: @event %>

<%= link_to 'イベント一覧に戻る', events_path %>
```

`app/views/events/edit.html.erb`:

```erb
<h2>イベントを編集</h2>

<%= render 'form', event: @event %>

<%= link_to '詳細', @event %> |
<%= link_to 'イベント一覧に戻る', events_path %>
```

### Task 9-4: レイアウトのナビゲーション更新

`app/views/layouts/application.html.erb`:

```erb
<nav>
  <%= link_to '書籍一覧', books_path %> |
  <%= link_to 'イベント一覧', events_path %>
  
  <span style="float: right;">
    <% if logged_in? %>
      👤 <%= current_user.name %> |
      <%= button_to 'ログアウト', logout_path, method: :delete, 
          data: { turbo: false }, 
          style: 'display: inline; background: none; border: none; color: #3498db; cursor: pointer; text-decoration: underline;' %>
    <% else %>
      <%= button_to 'GitHubでログイン', '/auth/github', method: :post, 
          data: { turbo: false },
          style: 'display: inline; background: #24292e; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;' %>
    <% end %>
  </span>
</nav>
```

### Task 9-5: 動作確認

```bash
# サーバー再起動
docker compose restart web

# ブラウザで確認
# http://localhost:3000/events
```

✅ **確認ポイント**:
1. イベント一覧が表示される
2. ログインしてイベントを作成できる
3. イベント詳細ページで参加できる
4. 参加者一覧が表示される
5. 参加をキャンセルできる
6. 主催者のみ編集・削除ボタンが表示される

```bash
git add .
git commit -m "Add Events CRUD and participation functionality"
```

---

## Phase 10: Active Job（5章 5-1）

### 📚 学習ポイント
- Sidekiqの設定
- ジョブクラスの作成
- perform_laterでの非同期実行
- キューアダプタの設定

### Task 10-1: Gemfile更新

`Gemfile`に追加:

```ruby
# 非同期ジョブ処理
gem 'sidekiq', '~> 7.0'
```

```bash
docker compose exec web bundle install
```

### Task 10-2: Sidekiq設定

`config/application.rb`に追加:

```ruby
module EventHub
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
    
    config.middleware.use Middleware::RequestTimer
    
    # Active Job設定
    config.active_job.queue_adapter = :sidekiq
  end
end
```

`config/sidekiq.yml`を作成:

```yaml
:concurrency: 5

:queues:
  - default
  - mailers
  - low_priority

:max_retries: 3
```

`config/initializers/sidekiq.rb`を作成:

```ruby
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end
```

### Task 10-3: EventReminderJob作成

```bash
docker compose exec web rails generate job EventReminder
```

`app/jobs/event_reminder_job.rb`:

```ruby
class EventReminderJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find(event_id)
    
    Rails.logger.info "===== イベントリマインダー送信 ====="
    Rails.logger.info "イベント: #{event.name}"
    Rails.logger.info "開始時刻: #{event.start_at.strftime('%Y年%m月%d日 %H時%M分')}"
    Rails.logger.info "参加者数: #{event.participants.count}"
    
    event.participants.each do |participant|
      Rails.logger.info "  - #{participant.name}（#{participant.email}）にリマインダー送信"
      # 後でメール送信を追加
      # EventMailer.reminder(event, participant).deliver_now
    end
    
    Rails.logger.info "リマインダー送信完了"
    Rails.logger.info "=============================="
  end
end
```

### Task 10-4: DailyReminderJob作成（定期実行用）

```bash
docker compose exec web rails generate job DailyReminder
```

`app/jobs/daily_reminder_job.rb`:

```ruby
class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform
    # 明日開催されるイベントを取得
    tomorrow_start = 1.day.from_now.beginning_of_day
    tomorrow_end = 1.day.from_now.end_of_day
    
    events = Event.where(start_at: tomorrow_start..tomorrow_end)
    
    Rails.logger.info "===== 明日のイベントリマインダー ====="
    Rails.logger.info "対象イベント数: #{events.count}"
    
    events.each do |event|
      EventReminderJob.perform_later(event.id)
    end
    
    Rails.logger.info "=============================="
  end
end
```

### Task 10-5: rails consoleでジョブテスト

```bash
docker compose exec web rails c
```

```ruby
# イベント取得
event = Event.first

# 即座に実行（perform_now）
EventReminderJob.perform_now(event.id)

# 非同期で実行（perform_later）
EventReminderJob.perform_later(event.id)

# 5秒後に実行
EventReminderJob.set(wait: 5.seconds).perform_later(event.id)

# 特定の時刻に実行
EventReminderJob.set(wait_until: 1.hour.from_now).perform_later(event.id)

exit
```

### Task 10-6: Sidekiq Web UI設定（オプション）

`config/routes.rb`に追加:

```ruby
require 'sidekiq/web'

Rails.application.routes.draw do
  # Sidekiq Web UI（開発環境のみ）
  if Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
  end
  
  resources :users
  resources :books
  resources :events do
    member do
      post :participate
      delete :cancel_participation
    end
  end
  
  # OAuth認証
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  delete '/logout', to: 'sessions#destroy'
  
  root 'books#index'
end
```

### Task 10-7: 動作確認

```bash
# Sidekiqコンテナの起動確認
docker compose ps

# Sidekiqのログ確認
docker compose logs -f sidekiq

# ブラウザで確認
# http://localhost:3000/sidekiq （Sidekiq Web UI）
```

```bash
# rails consoleでジョブをエンキュー
docker compose exec web rails c
```

```ruby
event = Event.first
EventReminderJob.perform_later(event.id)
exit
```

```bash
# Sidekiqのログを確認
docker compose logs sidekiq

# 出力例:
# ===== イベントリマインダー送信 =====
# イベント: パーフェクトRails 読書会 #1
# ...
```

```bash
git add .
git commit -m "Add Active Job with Sidekiq for event reminders"
```

---

## Phase 11: Action Mailer（5章 5-3）

### 📚 学習ポイント
- メーラークラスの作成
- メールテンプレート（text/html）
- deliver_now / deliver_later
- メール送信のテスト

### Task 11-1: メーラー生成

```bash
docker compose exec web rails generate mailer EventMailer \
  participation_confirmation \
  event_reminder
```

生成されるファイル:
- `app/mailers/event_mailer.rb`
- `app/views/event_mailer/participation_confirmation.text.erb`
- `app/views/event_mailer/participation_confirmation.html.erb`
- `app/views/event_mailer/event_reminder.text.erb`
- `app/views/event_mailer/event_reminder.html.erb`

### Task 11-2: EventMailer実装

`app/mailers/event_mailer.rb`:

```ruby
class EventMailer < ApplicationMailer
  default from: 'noreply@eventhub.example.com'

  def participation_confirmation(participation)
    @participation = participation
    @event = participation.event
    @user = participation.user
    
    mail(
      to: @user.email,
      subject: "【EventHub】#{@event.name} への参加を受け付けました"
    )
  end

  def event_reminder(event, user)
    @event = event
    @user = user
    @participation = event.participations.find_by(user: user)
    
    mail(
      to: @user.email,
      subject: "【EventHub】明日開催: #{@event.name}"
    )
  end
end
```

### Task 11-3: メールテンプレート作成

`app/views/event_mailer/participation_confirmation.text.erb`:

```erb
<%= @user.name %> 様

イベントへの参加を受け付けました。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
■ イベント情報
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

イベント名: <%= @event.name %>
関連書籍: <%= @event.book.title %>
場所: <%= @event.location %>
開始日時: <%= l(@event.start_at, format: :long) %>
終了日時: <%= l(@event.end_at, format: :long) %>

定員: <%= @event.capacity %>人
現在の参加者数: <%= @event.participants.count %>人

<% if @participation.comment.present? %>
あなたのコメント: 「<%= @participation.comment %>」
<% end %>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

イベント詳細: http://localhost:3000/events/<%= @event.id %>

当日のご参加をお待ちしております！

---
EventHub - 技術書イベントプラットフォーム
```

`app/views/event_mailer/participation_confirmation.html.erb`:

```erb
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: #3498db; color: white; padding: 20px; text-align: center; }
    .content { background: #f9f9f9; padding: 20px; margin: 20px 0; border-radius: 4px; }
    .info-row { margin: 10px 0; }
    .label { font-weight: bold; color: #555; }
    .footer { text-align: center; color: #999; font-size: 12px; margin-top: 30px; }
    .btn { 
      display: inline-block; 
      background: #3498db; 
      color: white; 
      padding: 12px 24px; 
      text-decoration: none; 
      border-radius: 4px; 
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📚 EventHub</h1>
    </div>
    
    <p><%= @user.name %> 様</p>
    
    <p>イベントへの参加を受け付けました。</p>
    
    <div class="content">
      <h2 style="margin-top: 0;">イベント情報</h2>
      
      <div class="info-row">
        <span class="label">イベント名:</span> <%= @event.name %>
      </div>
      
      <div class="info-row">
        <span class="label">関連書籍:</span> <%= @event.book.title %>
      </div>
      
      <div class="info-row">
        <span class="label">場所:</span> <%= @event.location %>
      </div>
      
      <div class="info-row">
        <span class="label">開始日時:</span> <%= l(@event.start_at, format: :long) %>
      </div>
      
      <div class="info-row">
        <span class="label">終了日時:</span> <%= l(@event.end_at, format: :long) %>
      </div>
      
      <div class="info-row">
        <span class="label">定員:</span> <%= @event.capacity %>人
      </div>
      
      <div class="info-row">
        <span class="label">現在の参加者数:</span> <%= @event.participants.count %>人
      </div>
      
      <% if @participation.comment.present? %>
        <div class="info-row" style="margin-top: 20px; padding: 10px; background: white; border-left: 4px solid #3498db;">
          <span class="label">あなたのコメント:</span><br>
          「<%= @participation.comment %>」
        </div>
      <% end %>
    </div>
    
    <div style="text-align: center;">
      <a href="http://localhost:3000/events/<%= @event.id %>" class="btn">
        イベント詳細を見る
      </a>
    </div>
    
    <p>当日のご参加をお待ちしております！</p>
    
    <div class="footer">
      EventHub - 技術書イベントプラットフォーム
    </div>
  </div>
</body>
</html>
```

`app/views/event_mailer/event_reminder.text.erb`:

```erb
<%= @user.name %> 様

明日、ご参加予定のイベントのリマインダーです。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
■ イベント情報
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

イベント名: <%= @event.name %>
関連書籍: <%= @event.book.title %>
場所: <%= @event.location %>
開始日時: <%= l(@event.start_at, format: :long) %>
終了日時: <%= l(@event.end_at, format: :long) %>

主催者: <%= @event.user.name %>
参加者数: <%= @event.participants.count %>人

<% if @participation && @participation.comment.present? %>
あなたのコメント: 「<%= @participation.comment %>」
<% end %>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

イベント詳細: http://localhost:3000/events/<%= @event.id %>

お忘れなく、ご参加をお待ちしております！

---
EventHub - 技術書イベントプラットフォーム
```

`app/views/event_mailer/event_reminder.html.erb`:

```erb
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: #e74c3c; color: white; padding: 20px; text-align: center; }
    .content { background: #fff3cd; padding: 20px; margin: 20px 0; border-radius: 4px; border-left: 4px solid #e74c3c; }
    .info-row { margin: 10px 0; }
    .label { font-weight: bold; color: #555; }
    .footer { text-align: center; color: #999; font-size: 12px; margin-top: 30px; }
    .btn { 
      display: inline-block; 
      background: #e74c3c; 
      color: white; 
      padding: 12px 24px; 
      text-decoration: none; 
      border-radius: 4px; 
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>⏰ イベントリマインダー</h1>
    </div>
    
    <p><%= @user.name %> 様</p>
    
    <p><strong>明日、ご参加予定のイベントのリマインダーです。</strong></p>
    
    <div class="content">
      <h2 style="margin-top: 0;">📅 イベント情報</h2>
      
      <div class="info-row">
        <span class="label">イベント名:</span> <%= @event.name %>
      </div>
      
      <div class="info-row">
        <span class="label">関連書籍:</span> <%= @event.book.title %>
      </div>
      
      <div class="info-row">
        <span class="label">場所:</span> <%= @event.location %>
      </div>
      
      <div class="info-row">
        <span class="label">開始日時:</span> <%= l(@event.start_at, format: :long) %>
      </div>
      
      <div class="info-row">
        <span class="label">終了日時:</span> <%= l(@event.end_at, format: :long) %>
      </div>
      
      <div class="info-row">
        <span class="label">主催者:</span> <%= @event.user.name %>
      </div>
      
      <div class="info-row">
        <span class="label">参加者数:</span> <%= @event.participants.count %>人
      </div>
      
      <% if @participation && @participation.comment.present? %>
        <div class="info-row" style="margin-top: 20px; padding: 10px; background: white; border-left: 4px solid #3498db;">
          <span class="label">あなたのコメント:</span><br>
          「<%= @participation.comment %>」
        </div>
      <% end %>
    </div>
    
    <div style="text-align: center;">
      <a href="http://localhost:3000/events/<%= @event.id %>" class="btn">
        イベント詳細を見る
      </a>
    </div>
    
    <p>お忘れなく、ご参加をお待ちしております！</p>
    
    <div class="footer">
      EventHub - 技術書イベントプラットフォーム
    </div>
  </div>
</body>
</html>
```

### Task 11-4: メール送信設定（開発環境）

`config/environments/development.rb`に追加:

```ruby
Rails.application.configure do
  # 既存の設定...
  
  # メール送信設定
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
end
```

### Task 11-5: EventsControllerでメール送信

`app/controllers/events_controller.rb`の`participate`アクションを更新:

```ruby
def participate
  @participation = @event.participations.build(
    user: current_user,
    comment: params[:comment]
  )
  
  if @participation.save
    # メール送信（非同期）
    EventMailer.participation_confirmation(@participation).deliver_later
    
    redirect_to @event, notice: 'イベントに参加しました。確認メールを送信しました。'
  else
    redirect_to @event, alert: @participation.errors.full_messages.join(', ')
  end
end
```

### Task 11-6: EventReminderJobを更新

`app/jobs/event_reminder_job.rb`:

```ruby
class EventReminderJob < ApplicationJob
  queue_as :mailers

  def perform(event_id)
    event = Event.find(event_id)
    
    Rails.logger.info "===== イベントリマインダー送信 ====="
    Rails.logger.info "イベント: #{event.name}"
    Rails.logger.info "開始時刻: #{event.start_at.strftime('%Y年%m月%d日 %H時%M分')}"
    Rails.logger.info "参加者数: #{event.participants.count}"
    
    event.participants.each do |participant|
      Rails.logger.info "  - #{participant.name}（#{participant.email}）にリマインダー送信"
      EventMailer.event_reminder(event, participant).deliver_now
    end
    
    Rails.logger.info "リマインダー送信完了"
    Rails.logger.info "=============================="
  end
end
```

### Task 11-7: rails consoleでメール送信テスト

```bash
docker compose exec web rails c
```

```ruby
# 参加データ作成
event = Event.first
user = User.second
participation = Participation.create!(
  event: event,
  user: user,
  comment: "楽しみです！"
)

# メール送信テスト
EventMailer.participation_confirmation(participation).deliver_now

# 送信されたメールを確認
ActionMailer::Base.deliveries.last

# メールの内容確認
mail = ActionMailer::Base.deliveries.last
mail.subject # => "【EventHub】パーフェクトRails 読書会 #1 への参加を受け付けました"
mail.to # => ["hanako@example.com"]
mail.body.to_s # => メール本文

# HTMLパート確認
mail.html_part.body.to_s

# テキストパート確認
mail.text_part.body.to_s

exit
```

### Task 11-8: メールプレビュー機能（開発支援）

`test/mailers/previews/event_mailer_preview.rb`を作成:

```ruby
class EventMailerPreview < ActionMailer::Preview
  def participation_confirmation
    participation = Participation.first
    EventMailer.participation_confirmation(participation)
  end

  def event_reminder
    event = Event.first
    user = event.participants.first
    EventMailer.event_reminder(event, user)
  end
end
```

ブラウザで確認:
- http://localhost:3000/rails/mailers

### Task 11-9: 動作確認

```bash
# サーバー再起動
docker compose restart web

# ブラウザで確認
# 1. http://localhost:3000/events にアクセス
# 2. ログインしてイベントに参加
# 3. rails consoleでメール確認
```

```bash
docker compose exec web rails c
```

```ruby
# 最新のメール確認
ActionMailer::Base.deliveries.last.subject

# メール一覧
ActionMailer::Base.deliveries.map(&:subject)

exit
```

```bash
git add .
git commit -m "Add Action Mailer for event notifications"
```

---

## Phase 12: 検索・ページネーション（6章）

### 📚 学習ポイント
- Kaminariでページネーション
- 検索機能の実装
- クエリパラメータの扱い

### Task 12-1: Kaminari導入

`Gemfile`に追加:

```ruby
# ページネーション
gem 'kaminari', '~> 1.2'
```

```bash
docker compose exec web bundle install
docker compose restart web
```

Kaminari設定ファイル生成:

```bash
docker compose exec web rails generate kaminari:config
```

`config/initializers/kaminari_config.rb`を編集:

```ruby
Kaminari.configure do |config|
  config.default_per_page = 10
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
  # config.max_pages = nil
  # config.params_on_first_page = false
end
```

### Task 12-2: BooksControllerにページネーション追加

`app/controllers/books_controller.rb`:

```ruby
def index
  @books = Book.includes(:user, :genres).recent.page(params[:page]).per(10)
end
```

### Task 12-3: Books index viewにページネーション追加

`app/views/books/index.html.erb`の最後に追加:

```erb
<div style="margin-top: 30px; text-align: center;">
  <%= paginate @books %>
</div>
```

### Task 12-4: EventsControllerにページネーションと検索追加

`app/controllers/events_controller.rb`:

```ruby
def index
  @events = Event.includes(:book, :user, :participants).upcoming
  
  # キーワード検索
  if params[:keyword].present?
    keyword = "%#{params[:keyword]}%"
    @events = @events.joins(:book).where(
      "events.name LIKE ? OR events.description LIKE ? OR events.location LIKE ? OR books.title LIKE ?",
      keyword, keyword, keyword, keyword
    )
  end
  
  @events = @events.page(params[:page]).per(9)
end
```

### Task 12-5: Events index viewに検索フォームとページネーション追加

`app/views/events/index.html.erb`の先頭を更新:

```erb
<h2>🎉 イベント一覧</h2>

<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
  <% if logged_in? %>
    <%= link_to '➕ 新しいイベントを作成', new_event_path, class: 'btn' %>
  <% end %>
  
  <%= form_with url: events_path, method: :get, local: true, style: 'display: flex; gap: 10px;' do |f| %>
    <%= f.text_field :keyword, 
        value: params[:keyword], 
        placeholder: 'イベント名、場所、書籍名で検索...',
        style: 'padding: 8px; border: 1px solid #ddd; border-radius: 4px; width: 300px;' %>
    <%= f.submit '🔍 検索', class: 'btn' %>
    <% if params[:keyword].present? %>
      <%= link_to 'クリア', events_path, class: 'btn' %>
    <% end %>
  <% end %>
</div>

<% if params[:keyword].present? %>
  <p style="color: #666;">
    「<%= params[:keyword] %>」の検索結果: <%= @events.total_count %>件
  </p>
<% end %>

<% if @events.any? %>
  <!-- 既存のイベント一覧 -->
  <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px;">
    <!-- ... 既存のコード ... -->
  </div>
  
  <!-- ページネーション追加 -->
  <div style="margin-top: 30px; text-align: center;">
    <%= paginate @events %>
  </div>
<% else %>
  <% if params[:keyword].present? %>
    <p>「<%= params[:keyword] %>」に一致するイベントは見つかりませんでした。</p>
  <% else %>
    <p>現在、開催予定のイベントはありません。</p>
  <% end %>
<% end %>
```

### Task 12-6: Kaminariのビューテンプレートカスタマイズ（オプション）

```bash
docker compose exec web rails generate kaminari:views default
```

生成されたファイル（`app/views/kaminari/`）をカスタマイズ可能。

### Task 12-7: 動作確認

```bash
# サーバー再起動
docker compose restart web

# ブラウザで確認
# http://localhost:3000/books
# http://localhost:3000/events
```

✅ **確認ポイント**:
1. 書籍一覧でページネーションが動作する
2. イベント一覧で検索ができる
3. 検索結果がページネーションされる

```bash
git add .
git commit -m "Add pagination and search functionality"
```

---

## Phase 13: Concern（13章 13-1）

### 📚 学習ポイント
- Concernの仕組み
- ActiveSupport::Concern
- 共通機能のモジュール化

### Task 13-1: Searchable concern作成

`app/models/concerns/searchable.rb`を作成:

```ruby
module Searchable
  extend ActiveSupport::Concern

  included do
    # インスタンスメソッドやクラスメソッドを定義できる
  end

  class_methods do
    def search_by_keyword(keyword)
      return all if keyword.blank?
      
      # サブクラスで定義されたsearchable_columnsを使用
      columns = searchable_columns.map { |col| "#{table_name}.#{col} LIKE :keyword" }.join(' OR ')
      where(columns, keyword: "%#{keyword}%")
    end
    
    # サブクラスで定義する必要があるメソッド
    def searchable_columns
      raise NotImplementedError, "#{self.class.name} must implement searchable_columns"
    end
  end
end
```

### Task 13-2: Timestampable concern作成

`app/models/concerns/timestampable.rb`を作成:

```ruby
module Timestampable
  extend ActiveSupport::Concern

  included do
    # コールバック定義
    before_create :log_creation
    before_update :log_update
  end

  private

  def log_creation
    Rails.logger.info "[#{self.class.name}] 新規作成: ID=#{id || 'pending'}"
  end

  def log_update
    Rails.logger.info "[#{self.class.name}] 更新: ID=#{id}, 変更カラム=#{changed.join(', ')}"
  end
end
```

### Task 13-3: BookモデルにSearchable適用

`app/models/book.rb`:

```ruby
class Book < ApplicationRecord
  include Searchable
  
  # リレーション
  belongs_to :user
  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres
  has_many :events, dependent: :destroy

  # Enum
  enum status: { available: 0, sold_out: 1, discontinued: 2 }

  # バリデーション
  validates :title, presence: true, length: { maximum: 200 }
  validates :isbn, presence: true, uniqueness: true, format: { 
    with: /\A\d{13}\z/, 
    message: "は13桁の数字で入力してください" 
  }
  validates :author_name, presence: true, length: { maximum: 100 }
  validates :publisher, length: { maximum: 100 }, allow_blank: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :stock_must_be_zero_if_sold_out

  # コールバック
  before_save :normalize_isbn
  after_create :log_book_creation

  # scope
  scope :available_books, -> { where(status: :available) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :in_stock, -> { where("stock > ?", 0) }
  scope :expensive, -> { where("price >= ?", 3000) }
  scope :recent, -> { order(created_at: :desc) }

  # Searchable concernのために定義
  def self.searchable_columns
    [:title, :author_name, :publisher, :isbn]
  end

  private

  def stock_must_be_zero_if_sold_out
    if sold_out? && stock.to_i > 0
      errors.add(:stock, "は売り切れのため0にする必要があります")
    end
  end

  def normalize_isbn
    self.isbn = isbn.gsub(/\D/, '') if isbn.present?
  end

  def log_book_creation
    Rails.logger.info "新しい書籍が登録されました: #{title} (ISBN: #{isbn})"
  end
end
```

### Task 13-4: EventモデルにSearchable適用

`app/models/event.rb`:

```ruby
class Event < ApplicationRecord
  include Searchable
  
  belongs_to :book
  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :location, presence: true, length: { maximum: 100 }
  validates :capacity, presence: true, numericality: { 
    only_integer: true, 
    greater_than: 0,
    less_than_or_equal_to: 1000
  }
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_at_after_start_at

  # scope
  scope :upcoming, -> { where("start_at >= ?", Time.current).order(start_at: :asc) }
  scope :past, -> { where("start_at < ?", Time.current).order(start_at: :desc) }
  scope :by_book, ->(book_id) { where(book_id: book_id) }
  scope :recent, -> { order(created_at: :desc) }

  # Searchable concernのために定義
  def self.searchable_columns
    [:name, :description, :location]
  end

  # ビジネスロジック
  def full?
    participations.count >= capacity
  end

  def available_seats
    capacity - participations.count
  end

  def started?
    start_at <= Time.current
  end

  def finished?
    end_at <= Time.current
  end

  def ongoing?
    started? && !finished?
  end

  def participated_by?(user)
    return false unless user
    participants.include?(user)
  end

  def created_by?(user)
    return false unless user
    self.user_id == user.id
  end

  private

  def end_at_after_start_at
    return if start_at.blank? || end_at.blank?
    
    if end_at <= start_at
      errors.add(:end_at, "は開始時刻より後に設定してください")
    end
  end
end
```

### Task 13-5: BooksControllerで検索機能を追加

`app/controllers/books_controller.rb`:

```ruby
def index
  @books = Book.includes(:user, :genres)
  
  # キーワード検索（Searchable concernを使用）
  if params[:keyword].present?
    @books = @books.search_by_keyword(params[:keyword])
  end
  
  @books = @books.recent.page(params[:page]).per(10)
end
```

### Task 13-6: Books index viewに検索フォーム追加

`app/views/books/index.html.erb`の先頭を更新:

```erb
<h2>📚 書籍一覧</h2>

<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
  <%= link_to '➕ 新しい書籍を登録', new_book_path, class: 'btn' %>
  
  <%= form_with url: books_path, method: :get, local: true, style: 'display: flex; gap: 10px;' do |f| %>
    <%= f.text_field :keyword, 
        value: params[:keyword], 
        placeholder: 'タイトル、著者、出版社、ISBNで検索...',
        style: 'padding: 8px; border: 1px solid #ddd; border-radius: 4px; width: 300px;' %>
    <%= f.submit '🔍 検索', class: 'btn' %>
    <% if params[:keyword].present? %>
      <%= link_to 'クリア', books_path, class: 'btn' %>
    <% end %>
  <% end %>
</div>

<% if params[:keyword].present? %>
  <p style="color: #666;">
    「<%= params[:keyword] %>」の検索結果: <%= @books.total_count %>件
  </p>
<% end %>
```

### Task 13-7: EventsControllerを更新（Searchable concern使用）

`app/controllers/events_controller.rb`:

```ruby
def index
  @events = Event.includes(:book, :user, :participants).upcoming
  
  # キーワード検索（Searchable concernを使用）
  if params[:keyword].present?
    # イベント自体を検索
    @events = @events.search_by_keyword(params[:keyword])
    
    # または書籍名でも検索
    book_ids = Book.search_by_keyword(params[:keyword]).pluck(:id)
    if book_ids.any?
      @events = @events.or(Event.where(book_id: book_ids))
    end
  end
  
  @events = @events.page(params[:page]).per(9)
end
```

### Task 13-8: rails consoleでConcernの動作確認

```bash
docker compose exec web rails c
```

```ruby
# Searchable concernのテスト
Book.search_by_keyword("Rails") # => Railsを含む書籍
Event.search_by_keyword("読書会") # => 読書会を含むイベント

# searchable_columnsの確認
Book.searchable_columns # => [:title, :author_name, :publisher, :isbn]
Event.searchable_columns # => [:name, :description, :location]

exit
```

### Task 13-9: 動作確認

```bash
# サーバー再起動
docker compose restart web

# ブラウザで確認
# http://localhost:3000/books?keyword=Rails
# http://localhost:3000/events?keyword=読書会
```

✅ **確認ポイント**:
1. 書籍一覧で検索ができる
2. イベント一覧で検索ができる
3. Concernで共通化されたコードが動作する

```bash
git add .
git commit -m "Add Concern modules for code reusability"
```

---

## Phase 14: テスト（7章）

### 📚 学習ポイント
- RSpecの設定
- factory_botでテストデータ作成
- Model spec（単体テスト）
- Controller spec（機能テスト）
- System spec（統合テスト）

### Task 14-1: RSpec & factory_bot導入

`Gemfile`のtest groupを更新:

```ruby
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.2'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'faker', '~> 3.2'
end
```

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
