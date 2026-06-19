# Phase 1: Docker環境構築（10章 10-1〜10-3）

**所要時間**: 30分  
**難易度**: ⭐⭐  

[← 目次に戻る](../README.md) | [← Phase 0](phase-00-environment-setup.md) | [Phase 2 →](phase-02-basic-models.md)

---


### 📚 学習ポイント
- Dockerの基礎
- docker-compose.ymlの構成
- Railsコンテナの構築
- MySQLコンテナとの連携

### Task 1-1: Dockerfile作成

`Dockerfile`を作成:

```dockerfile
FROM ruby:3.3.5

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
- `FROM ruby:3.3.5`: Ruby 3.3.5のDockerイメージを使用
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
git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby '3.3.5'

gem 'rails', '~> 7.2.2'
gem 'mysql2', '~> 0.5'
gem 'puma', '~> 6.4.3'
gem 'sass-rails', '>= 6'
gem 'webpacker'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', require: false

# 後で追加する gem
# gem 'omniauth-github'
# gem 'omniauth-rails_csrf_protection'
# gem 'kaminari'
# gem 'sidekiq'

group :development, :test do
  gem 'debug'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'faker'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'listen'
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


---

## ✅ Phase 1 完了チェック

- [ ] Dockerfileが作成されている
- [ ] docker-compose.ymlが作成されている
- [ ] Railsプロジェクトが作成されている
- [ ] http://localhost:3000 でRailsウェルカムページが表示される
- [ ] `rails db:version`が実行できる
- [ ] Gitで初回コミットを作成した

---

## 🎯 次のステップ

Docker環境が完成しました！次は **[Phase 2: 基本モデル構築](phase-02-basic-models.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase 0](phase-00-environment-setup.md) | [Phase 2 →](phase-02-basic-models.md)
