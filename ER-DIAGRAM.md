# EventHub ER図

```mermaid
erDiagram
    User ||--o{ Book : "registers"
    User ||--o{ Event : "creates"
    User ||--o{ Participation : "participates"
    
    Book }o--|| User : "registered_by"
    Book ||--o{ BookGenre : "has"
    Book ||--o{ Event : "featured_in"
    
    Genre ||--o{ BookGenre : "categorizes"
    
    Event }o--|| Book : "features"
    Event }o--|| User : "organized_by"
    Event ||--o{ Participation : "has"
    
    Participation }o--|| Event : "for"
    Participation }o--|| User : "by"

    User {
        integer id PK
        string name
        string email
        string provider "GitHub"
        string uid "GitHub_ID"
        datetime created_at
        datetime updated_at
    }

    Book {
        integer id PK
        string title
        string isbn "13桁"
        string author_name
        string publisher
        decimal price
        integer stock
        integer status "0:available,1:sold_out,2:discontinued"
        integer user_id FK
        datetime created_at
        datetime updated_at
    }

    Genre {
        integer id PK
        string name UK
        text description
        datetime created_at
        datetime updated_at
    }

    BookGenre {
        integer id PK
        integer book_id FK
        integer genre_id FK
        datetime created_at
        datetime updated_at
    }

    Event {
        integer id PK
        string name "max:50"
        text description "max:2000"
        string location "max:100"
        integer capacity "定員"
        datetime start_at
        datetime end_at
        string image_url
        integer book_id FK
        integer user_id FK
        datetime created_at
        datetime updated_at
    }

    Participation {
        integer id PK
        integer event_id FK
        integer user_id FK
        string comment "max:30"
        datetime created_at
        datetime updated_at
    }
```

---

## リレーション一覧

### User（ユーザー）
- `has_many :books` - 登録した技術書
- `has_many :events` - 主催したイベント
- `has_many :participations` - 参加したイベント
- `has_many :participated_events, through: :participations, source: :event`

### Book（技術書）
- `belongs_to :user` - 登録者
- `has_many :book_genres, dependent: :destroy`
- `has_many :genres, through: :book_genres` - ジャンル（多対多）
- `has_many :events` - この本に関連するイベント

### Genre（ジャンル）
- `has_many :book_genres, dependent: :destroy`
- `has_many :books, through: :book_genres` - 技術書（多対多）

### BookGenre（中間テーブル）
- `belongs_to :book`
- `belongs_to :genre`

### Event（イベント）
- `belongs_to :book` - 関連書籍
- `belongs_to :user` - 主催者
- `has_many :participations, dependent: :destroy`
- `has_many :participants, through: :participations, source: :user`

### Participation（イベント参加）
- `belongs_to :event`
- `belongs_to :user`

---

## キーポイント

### 多対多リレーション
1. **Book ←→ Genre**
   - 中間テーブル: `BookGenre`
   - 例: 「パーフェクトRails」は "Ruby" と "Rails" の両ジャンル

2. **User ←→ Event（参加者として）**
   - 中間テーブル: `Participation`
   - 例: あるユーザーが複数のイベントに参加

### Enum
- `Book.status`
  - `0`: available（販売中）
  - `1`: sold_out（売り切れ）
  - `2`: discontinued（販売終了）

### インデックス
- `Book.isbn` - ユニーク制約
- `User.email` - ユニーク制約
- `BookGenre(book_id, genre_id)` - 複合ユニーク制約
- `Participation(event_id, user_id)` - 複合ユニーク制約
