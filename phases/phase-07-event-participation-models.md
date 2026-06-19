# Phase event-participation-models: Event & Participation モデル（6章準備）

**所要時間**: 40分  
**難易度**: ⭐⭐⭐  

[← 目次に戻る](../README.md) | [← Phase credentials](phase-06-credentials.md) | [Phase github-oauth →](phase-08-github-oauth.md)

---


### 📚 学習ポイント
- イベントモデルの設計
- 参加機能の実装（多対多リレーション）
- 定員管理のビジネスロジック

### Task 7-1: Event model作成

```bash
# Event生成
docker compose exec web rails generate model Event \
  name:string \
  description:text \
  location:string \
  capacity:integer \
  start_at:datetime \
  end_at:datetime \
  image_url:string \
  book:references \
  user:references

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/event.rb`:

```ruby
class Event < ApplicationRecord
  belongs_to :book
  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user

  # バリデーション（6章）
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

  # scope（2章）
  scope :upcoming, -> { where("start_at >= ?", Time.current).order(start_at: :asc) }
  scope :past, -> { where("start_at < ?", Time.current).order(start_at: :desc) }
  scope :by_book, ->(book_id) { where(book_id: book_id) }
  scope :recent, -> { order(created_at: :desc) }

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

`app/models/book.rb`に追加:

```ruby
# 既存のリレーションに追加
has_many :events, dependent: :destroy
```

`app/models/user.rb`に追加:

```ruby
# 既存のリレーションに追加
has_many :events, dependent: :destroy
has_many :participations, dependent: :destroy
has_many :participated_events, through: :participations, source: :event
```

✅ **学習ポイント**:
- `has_many :through`で多対多リレーション
- カスタムバリデーション: `end_at_after_start_at`
- ビジネスロジックメソッド: `full?`, `available_seats`, `participated_by?`

### Task 7-2: Participation model作成

```bash
# Participation生成
docker compose exec web rails generate model Participation \
  event:references \
  user:references \
  comment:string

# マイグレーション実行
docker compose exec web rails db:migrate
```

`app/models/participation.rb`:

```ruby
class Participation < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :comment, length: { maximum: 30 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :event_id, message: "は既にこのイベントに参加しています" }
  validate :event_must_not_be_full
  validate :event_must_not_be_finished

  private

  def event_must_not_be_full
    return if event.blank?
    
    if event.full?
      errors.add(:base, "このイベントは定員に達しています")
    end
  end

  def event_must_not_be_finished
    return if event.blank?
    
    if event.finished?
      errors.add(:base, "このイベントは既に終了しています")
    end
  end
end
```

✅ **学習ポイント**:
- `uniqueness: { scope: :event_id }`: 同じユーザーが同じイベントに複数回参加できない
- カスタムバリデーション: 定員チェック、終了イベントチェック

### Task 7-3: rails consoleで動作確認

```bash
docker compose exec web rails c
```

```ruby
# ユーザーと書籍取得
user = User.first
book = Book.first

# イベント作成
event = Event.create!(
  name: "パーフェクトRails 読書会",
  description: "Rails本を読んで学ぶ勉強会です",
  location: "東京都渋谷区",
  capacity: 10,
  start_at: 1.week.from_now,
  end_at: 1.week.from_now + 2.hours,
  book: book,
  user: user
)

# イベント状態確認
event.upcoming? # => true
event.full? # => false
event.available_seats # => 10

# 参加者追加
user2 = User.second
participation = Participation.create!(
  event: event,
  user: user2,
  comment: "楽しみです！"
)

# リレーション確認
event.participants # => [user2]
user2.participated_events # => [event]
event.participated_by?(user2) # => true

# 定員確認
event.available_seats # => 9

exit
```

### Task 7-4: seeds.rbにイベントデータ追加

`db/seeds.rb`の最後に追加:

```ruby
# イベント作成
puts "Creating events..."

book1 = Book.find_by(isbn: '9784297114237') # パーフェクトRails
book2 = Book.find_by(isbn: '9784297124373') # Ruby入門
user1 = User.first

events_data = [
  {
    name: 'パーフェクトRails 読書会 #1',
    description: '第1章〜第3章を読んで、Railsの基礎を学びます。初心者歓迎！',
    location: '東京都渋谷区 渋谷駅前会議室',
    capacity: 20,
    start_at: 1.week.from_now.change(hour: 19, min: 0),
    end_at: 1.week.from_now.change(hour: 21, min: 0),
    image_url: 'https://via.placeholder.com/600x400?text=Rails+Study',
    book: book1,
    user: user1
  },
  {
    name: 'Ruby初心者もくもく会',
    description: 'Rubyを学び始めた方向けのもくもく会です。質問歓迎！',
    location: 'オンライン（Zoom）',
    capacity: 30,
    start_at: 10.days.from_now.change(hour: 14, min: 0),
    end_at: 10.days.from_now.change(hour: 17, min: 0),
    image_url: 'https://via.placeholder.com/600x400?text=Ruby+Mokumoku',
    book: book2,
    user: user1
  },
  {
    name: 'パーフェクトRails 著者サイン会',
    description: '著者が来場してサイン会を開催します！',
    location: '東京都千代田区 技術評論社本社',
    capacity: 50,
    start_at: 2.weeks.from_now.change(hour: 18, min: 0),
    end_at: 2.weeks.from_now.change(hour: 20, min: 0),
    image_url: 'https://via.placeholder.com/600x400?text=Book+Signing',
    book: book1,
    user: user1
  }
]

events_data.each do |event_data|
  Event.find_or_create_by!(
    name: event_data[:name],
    start_at: event_data[:start_at]
  ) do |event|
    event.assign_attributes(event_data)
  end
end

puts "#{Event.count} events created"

# サンプル参加データ
puts "Creating participations..."
event1 = Event.first
user2 = User.second
user3 = User.third

Participation.find_or_create_by!(event: event1, user: user2) do |p|
  p.comment = "楽しみにしています！"
end

Participation.find_or_create_by!(event: event1, user: user3) do |p|
  p.comment = "初心者ですがよろしくお願いします"
end

puts "#{Participation.count} participations created"
puts "All seed data created successfully!"
```

```bash
# seeds実行
docker compose exec web rails db:seed
```

```bash
git add .
git commit -m "Add Event and Participation models with business logic"
```

---


---

## ✅ Phase event-participation-models 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase github-oauth](phase-08-github-oauth.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase credentials](phase-06-credentials.md) | [Phase github-oauth →](phase-08-github-oauth.md)
