# Phase github-oauth: GitHub OAuth認証（6章 6-3）

**所要時間**: 40分  
**難易度**: ⭐⭐⭐⭐  

[← 目次に戻る](../README.md) | [← Phase event-participation-models](phase-07-event-participation-models.md) | [Phase event-management →](phase-09-event-management.md)

---


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


---

## ✅ Phase github-oauth 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase event-management](phase-09-event-management.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase event-participation-models](phase-07-event-participation-models.md) | [Phase event-management →](phase-09-event-management.md)
