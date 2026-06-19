# Phase database-management: DB管理（3章 3-3）

**所要時間**: 30分  
**難易度**: ⭐⭐  

[← 目次に戻る](../README.md) | [← Phase rack-middleware](phase-04-rack-middleware.md) | [Phase credentials →](phase-06-credentials.md)

---


### 📚 学習ポイント
- migration（カラム追加、rollback）
- seeds.rb（マスターデータ投入）
- db:migrate:status

### Task 5-1: カラム追加migration

```bash
# ページ数カラムを追加
docker compose exec web rails generate migration AddPageCountToBooks page_count:integer

# 生成されたファイルを確認
# db/migrate/XXXXXX_add_page_count_to_books.rb
```

生成されたマイグレーションファイル:

```ruby
class AddPageCountToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :page_count, :integer
  end
end
```

### Task 5-2: migration実行と確認

```bash
# migration状態確認
docker compose exec web rails db:migrate:status

# migration実行
docker compose exec web rails db:migrate

# 再度状態確認
docker compose exec web rails db:migrate:status
# "up" になっていることを確認
```

### Task 5-3: rollback練習

```bash
# 1つ戻す
docker compose exec web rails db:rollback

# 状態確認
docker compose exec web rails db:migrate:status
# 最新のmigrationが "down" になっていることを確認

# 再度実行して戻す
docker compose exec web rails db:migrate
```

### Task 5-4: カラムデフォルト値変更migration

```bash
docker compose exec web rails generate migration ChangeStockDefaultInBooks
```

生成されたファイルを編集:

```ruby
class ChangeStockDefaultInBooks < ActiveRecord::Migration[7.2]
  def up
    change_column_default :books, :stock, from: nil, to: 0
  end

  def down
    change_column_default :books, :stock, from: 0, to: nil
  end
end
```

```bash
docker compose exec web rails db:migrate
```

✅ **学習ポイント**:
- `up`/`down`で可逆性を保証
- `change`メソッドは自動で可逆性を判断

### Task 5-5: seeds.rb作成

`db/seeds.rb`を編集:

```ruby
# ユーザー作成
puts "Creating users..."
users = [
  { name: '山田太郎', email: 'taro@example.com' },
  { name: '佐藤花子', email: 'hanako@example.com' },
  { name: '鈴木一郎', email: 'ichiro@example.com' }
]

users.each do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.name = user_data[:name]
  end
end

puts "#{User.count} users created"

# ジャンル作成
puts "Creating genres..."
genres_data = [
  { name: 'Ruby', description: 'Ruby言語の技術書' },
  { name: 'Rails', description: 'Ruby on Railsの技術書' },
  { name: 'JavaScript', description: 'JavaScript関連の技術書' },
  { name: 'Python', description: 'Python関連の技術書' },
  { name: 'データベース', description: 'DB設計・SQL関連' },
  { name: 'インフラ', description: 'Docker・AWS等' }
]

genres_data.each do |genre_data|
  Genre.find_or_create_by!(name: genre_data[:name]) do |genre|
    genre.description = genre_data[:description]
  end
end

puts "#{Genre.count} genres created"

# 書籍作成
puts "Creating books..."
ruby_genre = Genre.find_by(name: 'Ruby')
rails_genre = Genre.find_by(name: 'Rails')
js_genre = Genre.find_by(name: 'JavaScript')
db_genre = Genre.find_by(name: 'データベース')
infra_genre = Genre.find_by(name: 'インフラ')

user1 = User.first
user2 = User.second

books_data = [
  {
    title: 'パーフェクト Ruby on Rails［増補改訂版］',
    isbn: '9784297114237',
    author_name: 'すがわらまさのり、前島真一、橋立友宏、五十嵐邦明',
    publisher: '技術評論社',
    price: 3608,
    stock: 15,
    page_count: 456,
    status: :available,
    user: user1,
    genres: [ruby_genre, rails_genre]
  },
  {
    title: 'プロを目指す人のためのRuby入門',
    isbn: '9784297124373',
    author_name: '伊藤淳一',
    publisher: '技術評論社',
    price: 3278,
    stock: 20,
    page_count: 512,
    status: :available,
    user: user1,
    genres: [ruby_genre]
  },
  {
    title: 'JavaScript本格入門',
    isbn: '9784297137663',
    author_name: '山田祥寛',
    publisher: '技術評論社',
    price: 3080,
    stock: 10,
    page_count: 624,
    status: :available,
    user: user2,
    genres: [js_genre]
  },
  {
    title: 'SQL実践入門',
    isbn: '9784774187013',
    author_name: 'ミック',
    publisher: '技術評論社',
    price: 2750,
    stock: 8,
    page_count: 304,
    status: :available,
    user: user2,
    genres: [db_genre]
  },
  {
    title: 'Docker実践ガイド',
    isbn: '9784295013464',
    author_name: '古賀政純',
    publisher: 'インプレス',
    price: 3520,
    stock: 0,
    page_count: 368,
    status: :sold_out,
    user: user1,
    genres: [infra_genre]
  }
]

books_data.each do |book_data|
  book_genres = book_data.delete(:genres)
  
  book = Book.find_or_create_by!(isbn: book_data[:isbn]) do |b|
    b.assign_attributes(book_data)
  end
  
  book_genres.each do |genre|
    BookGenre.find_or_create_by!(book: book, genre: genre)
  end
end

puts "#{Book.count} books created"
puts "Seed data created successfully!"
```

### Task 5-6: seeds実行

```bash
# seeds実行
docker compose exec web rails db:seed

# 確認
docker compose exec web rails c
```

```ruby
User.count # => 3
Genre.count # => 6
Book.count # => 5

# リレーション確認
book = Book.find_by(isbn: '9784297114237')
book.genres.map(&:name) # => ["Ruby", "Rails"]

exit
```

### Task 5-7: データベースリセット練習

```bash
# データベース全体をリセット（drop → create → migrate → seed）
docker compose exec web rails db:reset

# 確認
# http://localhost:3000/books
# 5冊の書籍が表示される
```

✅ **学習ポイント**:
- `db:seed`: seedsを実行
- `db:reset`: drop → create → migrate → seed を一括実行
- `find_or_create_by!`: 冪等性を保証（何度実行しても同じ結果）

```bash
git add .
git commit -m "Add migrations and seeds for initial data"
```

---


---

## ✅ Phase database-management 完了チェック

このフェーズの全タスクが完了したかチェックしてください。

---

## 🎯 次のステップ

次は **[Phase credentials](phase-06-credentials.md)** に進みましょう。

[← 目次に戻る](../README.md) | [← Phase rack-middleware](phase-04-rack-middleware.md) | [Phase credentials →](phase-06-credentials.md)
