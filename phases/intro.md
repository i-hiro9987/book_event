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

### Phase 0: 環境準備
- [ ] Docker / Docker Composeインストール確認
- [ ] プロジェクトディレクトリ作成

### Phase 1: Docker環境構築 (10章)
- [ ] Dockerfile作成
- [ ] docker-compose.yml作成
- [ ] Rails新規プロジェクト作成
- [ ] MySQL接続確認

### Phase 2: 基本モデル構築 (1章、2章)
- [ ] User scaffoldで基本CRUD体験
- [ ] Book modelの詳細実装（バリデーション、scope、Enum、コールバック）
- [ ] Genre & BookGenre（多対多リレーション）

### Phase 3: BooksController & Views作成 (2章)
- [ ] BooksController生成
- [ ] Books Views作成
- [ ] BooksHelper作成

### Phase 4: Rackミドルウェア (3-2)
- [ ] RequestTimerミドルウェア実装

### Phase 5: DB管理 (3-3)
- [ ] migration練習（カラム追加、rollback）
- [ ] seeds.rb作成
- [ ] マスターデータ投入

### Phase 6: 秘密情報管理 (3-4)
- [ ] credentials設定
- [ ] GitHub OAuth key管理

### Phase 7: Event & Participation モデル (6章準備)
- [ ] Event model作成
- [ ] Participation model作成

### Phase 8: GitHub OAuth認証 (6章)
- [ ] OmniAuth設定
- [ ] GitHub OAuth認証実装
- [ ] ログイン/ログアウト機能

### Phase 9: イベント管理機能 (6章)
- [ ] Event model & controller
- [ ] Participation model
- [ ] イベントCRUD、参加/キャンセル機能

### Phase 10: Active Job (5-1)
- [ ] Sidekiq設定
- [ ] EventReminderJob実装

### Phase 11: Action Mailer (5-3)
- [ ] ParticipationMailer実装
- [ ] EventReminderMailer実装

### Phase 12: 検索・ページネーション (6章)
- [ ] Kaminari導入
- [ ] 検索機能実装

### Phase 13: Concern (13-1)
- [ ] Searchable concern
- [ ] Timestampable concern

### Phase 14: テスト (7章)
- [ ] RSpec, factory_bot設定
- [ ] Model spec
- [ ] Controller spec
- [ ] System spec