# Phase rack-middleware: Rackミドルウェア（3章 3-2）

**所要時間**: 20分  
**難易度**: ⭐⭐  

[← 目次に戻る](../README.md) | [← Phase books-controller-views](phase-03-books-controller-views.md) | [Phase database-management →](phase-05-database-management.md)

---


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
    config.load_defaults 7.2
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


---

## ✅ Phase rack-middleware 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase database-management](phase-05-database-management.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase books-controller-views](phase-03-books-controller-views.md) | [Phase database-management →](phase-05-database-management.md)
