# Phase concern: Concern（13章 13-1）

**所要時間**: 30分  
**難易度**: ⭐⭐⭐  

[← 目次に戻る](../README.md) | [← Phase search-pagination](phase-12-search-pagination.md) | [Phase testing →](phase-14-testing.md)

---


### 📚 学習ポイント
- Concernの仕組み
- ActiveSupport::Concern
- 共通機能のモジュール化

### Task 13-1: Searchable concern作成

`app/models/concerns/searchable.rb`を作成:

```ruby
module Searchable
  extend ActiveSupport::Concern

  included do
    # インスタンスメソッドやクラスメソッドを定義できる
  end

  class_methods do
    def search_by_keyword(keyword)
      return all if keyword.blank?
      
      # サブクラスで定義されたsearchable_columnsを使用
      columns = searchable_columns.map { |col| "#{table_name}.#{col} LIKE :keyword" }.join(' OR ')
      where(columns, keyword: "%#{keyword}%")
    end
    
    # サブクラスで定義する必要があるメソッド
    def searchable_columns
      raise NotImplementedError, "#{self.class.name} must implement searchable_columns"
    end
  end
end
```

### Task 13-2: Timestampable concern作成

`app/models/concerns/timestampable.rb`を作成:

```ruby
module Timestampable
  extend ActiveSupport::Concern

  included do
    # コールバック定義
    before_create :log_creation
    before_update :log_update
  end

  private

  def log_creation
    Rails.logger.info "[#{self.class.name}] 新規作成: ID=#{id || 'pending'}"
  end

  def log_update
    Rails.logger.info "[#{self.class.name}] 更新: ID=#{id}, 変更カラム=#{changed.join(', ')}"
  end
end
```

### Task 13-3: BookモデルにSearchable適用

`app/models/book.rb`:

```ruby
class Book < ApplicationRecord
  include Searchable
  
  # リレーション
  belongs_to :user
  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres
  has_many :events, dependent: :destroy

  # Enum
  enum status: { available: 0, sold_out: 1, discontinued: 2 }

  # バリデーション
  validates :title, presence: true, length: { maximum: 200 }
  validates :isbn, presence: true, uniqueness: true, format: { 
    with: /\A\d{13}\z/, 
    message: "は13桁の数字で入力してください" 
  }
  validates :author_name, presence: true, length: { maximum: 100 }
  validates :publisher, length: { maximum: 100 }, allow_blank: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :stock_must_be_zero_if_sold_out

  # コールバック
  before_save :normalize_isbn
  after_create :log_book_creation

  # scope
  scope :available_books, -> { where(status: :available) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :in_stock, -> { where("stock > ?", 0) }
  scope :expensive, -> { where("price >= ?", 3000) }
  scope :recent, -> { order(created_at: :desc) }

  # Searchable concernのために定義
  def self.searchable_columns
    [:title, :author_name, :publisher, :isbn]
  end

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

### Task 13-4: EventモデルにSearchable適用

`app/models/event.rb`:

```ruby
class Event < ApplicationRecord
  include Searchable
  
  belongs_to :book
  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :location, presence: true, length: { maximum: 100 }
  validates :capacity, presence: true, numericality: { 
    only_integer: true, 
    greater_than: 0,
    less_than_or_equal_to: 1000
  }
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_at_after_start_at

  # scope
  scope :upcoming, -> { where("start_at >= ?", Time.current).order(start_at: :asc) }
  scope :past, -> { where("start_at < ?", Time.current).order(start_at: :desc) }
  scope :by_book, ->(book_id) { where(book_id: book_id) }
  scope :recent, -> { order(created_at: :desc) }

  # Searchable concernのために定義
  def self.searchable_columns
    [:name, :description, :location]
  end

  # ビジネスロジック
  def full?
    participations.count >= capacity
  end

  def available_seats
    capacity - participations.count
  end

  def started?
    start_at <= Time.current
  end

  def finished?
    end_at <= Time.current
  end

  def ongoing?
    started? && !finished?
  end

  def participated_by?(user)
    return false unless user
    participants.include?(user)
  end

  def created_by?(user)
    return false unless user
    self.user_id == user.id
  end

  private

  def end_at_after_start_at
    return if start_at.blank? || end_at.blank?
    
    if end_at <= start_at
      errors.add(:end_at, "は開始時刻より後に設定してください")
    end
  end
end
```

### Task 13-5: BooksControllerで検索機能を追加

`app/controllers/books_controller.rb`:

```ruby
def index
  @books = Book.includes(:user, :genres)
  
  # キーワード検索（Searchable concernを使用）
  if params[:keyword].present?
    @books = @books.search_by_keyword(params[:keyword])
  end
  
  @books = @books.recent.page(params[:page]).per(10)
end
```

### Task 13-6: Books index viewに検索フォーム追加

`app/views/books/index.html.erb`の先頭を更新:

```erb
<h2>📚 書籍一覧</h2>

<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
  <%= link_to '➕ 新しい書籍を登録', new_book_path, class: 'btn' %>
  
  <%= form_with url: books_path, method: :get, local: true, style: 'display: flex; gap: 10px;' do |f| %>
    <%= f.text_field :keyword, 
        value: params[:keyword], 
        placeholder: 'タイトル、著者、出版社、ISBNで検索...',
        style: 'padding: 8px; border: 1px solid #ddd; border-radius: 4px; width: 300px;' %>
    <%= f.submit '🔍 検索', class: 'btn' %>
    <% if params[:keyword].present? %>
      <%= link_to 'クリア', books_path, class: 'btn' %>
    <% end %>
  <% end %>
</div>

<% if params[:keyword].present? %>
  <p style="color: #666;">
    「<%= params[:keyword] %>」の検索結果: <%= @books.total_count %>件
  </p>
<% end %>
```

### Task 13-7: EventsControllerを更新（Searchable concern使用）

`app/controllers/events_controller.rb`:

```ruby
def index
  @events = Event.includes(:book, :user, :participants).upcoming
  
  # キーワード検索（Searchable concernを使用）
  if params[:keyword].present?
    # イベント自体を検索
    @events = @events.search_by_keyword(params[:keyword])
    
    # または書籍名でも検索
    book_ids = Book.search_by_keyword(params[:keyword]).pluck(:id)
    if book_ids.any?
      @events = @events.or(Event.where(book_id: book_ids))
    end
  end
  
  @events = @events.page(params[:page]).per(9)
end
```

### Task 13-8: rails consoleでConcernの動作確認

```bash
docker compose exec web rails c
```

```ruby
# Searchable concernのテスト
Book.search_by_keyword("Rails") # => Railsを含む書籍
Event.search_by_keyword("読書会") # => 読書会を含むイベント

# searchable_columnsの確認
Book.searchable_columns # => [:title, :author_name, :publisher, :isbn]
Event.searchable_columns # => [:name, :description, :location]

exit
```

### Task 13-9: 動作確認

```bash
# サーバー再起動
docker compose restart web

# ブラウザで確認
# http://localhost:3000/books?keyword=Rails
# http://localhost:3000/events?keyword=読書会
```

✅ **確認ポイント**:
1. 書籍一覧で検索ができる
2. イベント一覧で検索ができる
3. Concernで共通化されたコードが動作する

```bash
git add .
git commit -m "Add Concern modules for code reusability"
```

---


---

## ✅ Phase concern 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase testing](phase-14-testing.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase search-pagination](phase-12-search-pagination.md) | [Phase testing →](phase-14-testing.md)
