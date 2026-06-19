# Phase event-management: イベント管理機能（6章）

**所要時間**: 60分  
**難易度**: ⭐⭐⭐⭐  

[← 目次に戻る](../README.md) | [← Phase github-oauth](phase-08-github-oauth.md) | [Phase active-job →](phase-10-active-job.md)

---


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


---

## ✅ Phase event-management 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase active-job](phase-10-active-job.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase github-oauth](phase-08-github-oauth.md) | [Phase active-job →](phase-10-active-job.md)
