# Phase active-job: Active Job（5章 5-1）

**所要時間**: 30分  
**難易度**: ⭐⭐⭐  

[← 目次に戻る](../README.md) | [← Phase event-management](phase-09-event-management.md) | [Phase action-mailer →](phase-11-action-mailer.md)

---


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
    config.load_defaults 7.2
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


---

## ✅ Phase active-job 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase action-mailer](phase-11-action-mailer.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase event-management](phase-09-event-management.md) | [Phase action-mailer →](phase-11-action-mailer.md)
