puts "Creating Users..."
users = [
  {name: '山田太郎', email: "taro@example.com"},
  {name: '佐藤花子', email: "sato@example.com"},
  {name: '鈴木一郎', email: "suzuki@example.com"}
]

users.each do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.name = user_data[:name]
  end
end

puts "#{User.count} user created"

puts "Creating Genres..."
genres_data = [
  {name: "Ruby", description: "Ruby言語の技術書"},
  {name: "Rails", description: "Ruby on Railsの技術書"},
  {name: "JavaScript", description: "JavaScript関連の技術書"},
  {name: "Python", description: "Python関連の技術書"},
  {name: "データベース", description: "DB設計・SQL関連"},
  {name: "インフラ", description: "Docker・AWS等"}
]

genres_data.each do |genre_data|
  Genre.find_or_create_by!(name: genre_data[:name]) do |genre|
    genre.description = genre_data[:description]
  end
end

puts "#{Genre.count} genres created"

puts "Creating books..."
ruby_genre = Genre.find_by(name: "Ruby")
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
puts "Seed data created successfly!"

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
  p.comment = '楽しみにしています！'
end

Participation.find_or_create_by!(event: event1, user: user3) do |p|
  p.comment = '楽しみにしています！'
end

puts "#{Participation.count} participations created"
puts "All seed data created successfully!"
