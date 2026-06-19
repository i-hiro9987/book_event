# Phase action-mailer: Action Mailer（5章 5-3）

**所要時間**: 45分  
**難易度**: ⭐⭐⭐  

[← 目次に戻る](../README.md) | [← Phase active-job](phase-10-active-job.md) | [Phase search-pagination →](phase-12-search-pagination.md)

---


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


---

## ✅ Phase action-mailer 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase search-pagination](phase-12-search-pagination.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase active-job](phase-10-active-job.md) | [Phase search-pagination →](phase-12-search-pagination.md)
