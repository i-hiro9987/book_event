# Phase credentials: 秘密情報管理（3章 3-4）

**所要時間**: 15分  
**難易度**: ⭐⭐  

[← 目次に戻る](../README.md) | [← Phase database-management](phase-05-database-management.md) | [Phase event-participation-models →](phase-07-event-participation-models.md)

---


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


---

## ✅ Phase credentials 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase event-participation-models](phase-07-event-participation-models.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase database-management](phase-05-database-management.md) | [Phase event-participation-models →](phase-07-event-participation-models.md)
