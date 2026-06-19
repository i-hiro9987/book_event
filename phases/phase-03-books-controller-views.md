# Phase books-controller-views: BooksController & Views作成（2章）

**所要時間**: 45分  
**難易度**: ⭐⭐⭐  

[← 目次に戻る](../README.md) | [← Phase basic-models](phase-02-basic-models.md) | [Phase rack-middleware →](phase-04-rack-middleware.md)

---


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
    config.load_defaults 7.2
    
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


---

## ✅ Phase books-controller-views 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase rack-middleware](phase-04-rack-middleware.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase basic-models](phase-02-basic-models.md) | [Phase rack-middleware →](phase-04-rack-middleware.md)
