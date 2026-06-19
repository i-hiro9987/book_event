# Phase search-pagination: 検索・ページネーション（6章）

**所要時間**: 30分  
**難易度**: ⭐⭐  

[← 目次に戻る](../README.md) | [← Phase action-mailer](phase-11-action-mailer.md) | [Phase concern →](phase-13-concern.md)

---


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


---

## ✅ Phase search-pagination 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase concern](phase-13-concern.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase action-mailer](phase-11-action-mailer.md) | [Phase concern →](phase-13-concern.md)
