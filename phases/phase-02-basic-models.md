# Phase basic-models: 基本モデル構築（1章、2章）

**所要時間**: 60分  
**難易度**: ⭐⭐⭐  

[← 目次に戻る](../README.md) | [← Phase docker-setup](phase-01-docker-setup.md) | [Phase books-controller-views →](phase-03-books-controller-views.md)

---


### 📚 学習ポイント
- scaffoldでのCRUD体験（1章）
- モデルの詳細実装（2章）
  - バリデーション
  - リレーション（1対多、多対多）
  - scope
  - Enum
  - コールバック

### Task 2-1: User scaffoldで基本CRUD体験（1章）

```bash
# User scaffold生成
docker compose exec web rails generate scaffold User \
  name:string \
  email:string \
  provider:string \
  uid:string

# マイグレーション実行
docker compose exec web rails db:migrate

# ルーティング確認
docker compose exec web rails routes | grep user
```

**生成されるファイル**:
- Model: `app/models/user.rb`
- Controller: `app/controllers/users_controller.rb`
- Views: `app/views/users/`
- Migration: `db/migrate/XXXXXX_create_users.rb`
- Test: `test/models/user_test.rb`, `test/controllers/users_controller_test.rb`

✅ **動作確認**:
- http://localhost:3000/users にアクセス
- ユーザーを新規作成、編集、削除してみる

✅ **学習ポイント**:
- scaffoldで7つのRESTfulアクション（index, show, new, create, edit, update, destroy）が自動生成される
- `rails routes`でルーティングを確認
- MVC構造を体感

```bash
git add .
git commit -m "Add User scaffold"
```

### Task 2-2: Genre model作成（2章 リレーション準備）

```bash
# Genre生成
docker compose exec web rails generate model Genre \
  name:string \
  description:text

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/genre.rb`を編集:

```ruby
class Genre < ApplicationRecord
  has_many :book_genres, dependent: :destroy
  has_many :books, through: :book_genres

  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
end
```

✅ **学習ポイント**:
- `has_many :through`で多対多リレーションの準備
- バリデーション（presence, uniqueness, length）

### Task 2-3: Book model作成（2章 メイン実装）

```bash
# Book生成
docker compose exec web rails generate model Book \
  title:string \
  isbn:string \
  author_name:string \
  publisher:string \
  price:decimal \
  stock:integer \
  status:integer \
  user:references

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/book.rb`を編集:

```ruby
class Book < ApplicationRecord
  # リレーション
  belongs_to :user
  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres
  has_many :events, dependent: :destroy

  # Enum（2章 2-2-5）
  enum status: { available: 0, sold_out: 1, discontinued: 2 }

  # バリデーション（2章 2-2-3）
  validates :title, presence: true, length: { maximum: 200 }
  validates :isbn, presence: true, uniqueness: true, format: { 
    with: /\A\d{13}\z/, 
    message: "は13桁の数字で入力してください" 
  }
  validates :author_name, presence: true, length: { maximum: 100 }
  validates :publisher, length: { maximum: 100 }, allow_blank: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # カスタムバリデーション（2章 2-2-3）
  validate :stock_must_be_zero_if_sold_out

  # コールバック（2章 2-2-4）
  before_save :normalize_isbn
  after_create :log_book_creation

  # scope（2章 2-2-1）
  scope :available_books, -> { where(status: :available) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :in_stock, -> { where("stock > ?", 0) }
  scope :expensive, -> { where("price >= ?", 3000) }
  scope :recent, -> { order(created_at: :desc) }

  private

  def stock_must_be_zero_if_sold_out
    if sold_out? && stock.to_i > 0
      errors.add(:stock, "は売り切れのため0にする必要があります")
    end
  end

  def normalize_isbn
    self.isbn = isbn.gsub(/\D/, '') if isbn.present?
  end

  def log_book_creation
    Rails.logger.info "新しい書籍が登録されました: #{title} (ISBN: #{isbn})"
  end
end
```

`app/models/user.rb`に追加:

```ruby
class User < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :participations, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
```

✅ **学習ポイント**:
- **Enum**: `enum status: { available: 0, sold_out: 1, discontinued: 2 }`
  - `book.available?`, `book.sold_out!` などのメソッドが使える
- **scope**: 再利用可能なクエリ
- **コールバック**: `before_save`, `after_create`
- **カスタムバリデーション**: `validate :stock_must_be_zero_if_sold_out`

### Task 2-4: BookGenre（中間テーブル）作成

```bash
# BookGenre生成
docker compose exec web rails generate model BookGenre \
  book:references \
  genre:references

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/book_genre.rb`:

```ruby
class BookGenre < ApplicationRecord
  belongs_to :book
  belongs to :genre

  validates :book_id, uniqueness: { scope: :genre_id }
end
```

### Task 2-5: rails consoleでモデル動作確認

```bash
docker compose exec web rails c
```

```ruby
# ユーザー作成
user = User.create!(name: "山田太郎", email: "taro@example.com")

# ジャンル作成
ruby_genre = Genre.create!(name: "Ruby", description: "Ruby関連の技術書")
rails_genre = Genre.create!(name: "Rails", description: "Rails関連の技術書")

# 書籍作成
book = Book.create!(
  title: "パーフェクト Ruby on Rails",
  isbn: "9784297114237",
  author_name: "すがわらまさのり、前島真一、橋立友宏、五十嵐邦明",
  publisher: "技術評論社",
  price: 3608,
  stock: 10,
  status: :available,
  user: user
)

# ジャンル関連付け
book.book_genres.create!(genre: ruby_genre)
book.book_genres.create!(genre: rails_genre)

# リレーション確認
book.genres # => [ruby_genre, rails_genre]
ruby_genre.books # => [book]
user.books # => [book]

# Enum確認
book.available? # => true
book.sold_out! # statusが1に変わる
book.sold_out? # => true

# scope確認
Book.available_books
Book.in_stock
Book.expensive

# バリデーション確認
invalid_book = Book.new(title: "", isbn: "123") # title必須、isbn形式エラー
invalid_book.valid? # => false
invalid_book.errors.full_messages
# => ["Title can't be blank", "Isbnは13桁の数字で入力してください"]

exit
```

✅ **確認ポイント**:
- リレーションが正しく動作する
- Enumメソッド（`available?`, `sold_out!`）が使える
- scopeが動作する
- バリデーションが効く

```bash
git add .
git commit -m "Add Genre, Book, BookGenre models with validations, scopes, and callbacks"
```

---


---

## ✅ Phase basic-models 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase books-controller-views](phase-03-books-controller-views.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase docker-setup](phase-01-docker-setup.md) | [Phase books-controller-views →](phase-03-books-controller-views.md)
