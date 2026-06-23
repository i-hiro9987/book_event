require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "バリデーション" do
    it 'valid factory' do
      book = build(:book)
      expect(book).to be_valid
    end

    it 'タイトルが必須' do
      book = build(:book, title: nil)
      expect(book).not_to be_valid
      expect(book.errors[:title]).to be_present
    end

    it "ISBNは13桁の数字" do
      book = build(:book, isbn: '123')
      expect(book).not_to be_valid
      expect(book.errors[:isbn]).to be_present
    end

    it 'ISBNは一意' do
      create(:book, isbn: '9781234567890')
      book = build(:book, isbn: '9781234567890')
      expect(book).not_to be_valid
    end

    it '在庫は０以上の整数' do
      book = build(:book, stock: -1)
      expect(book).not_to be_valid
    end
  end

  describe 'リレーション' do
    it { should belong_to(:user) }
    it { should have_many(:book_genres).dependent(:destroy) }
    it { should have_many(:genres).through(:book_genres) }
    it { should have_many(:events).dependent(:destroy) }
  end

  describe 'Enum' do
    it { should define_enum_for(:status).with_values(available: 0, sold_out: 1, discontinued: 2) }

    it 'available?が動作する' do
      book = create(:book, status: :available)
      expect(book.available?).to be true
    end

    it 'sold_out!で状態を変更できる' do
      book = create(:book, status: :available)
      book.update!(status: :sold_out, stock: 0)
      expect(book.sold_out?).to be true
    end

    describe 'scope' do
      let!(:available_book) { create(:book, status: :available) }
      let!(:sold_out_book) { create(:book, :sold_out)}
      let!(:expensive_book) { create(:book, :expensive) }

      it 'available_booksは販売中の書籍のみ' do
        expect(Book.available_books).to include(available_book)
        expect(Book.available_books).not_to include(sold_out_book)
      end

      it 'expensiveは3000円以上の書籍' do
        expect(Book.expensive).to include(expensive_book)
      end
    end

    describe 'コールバック' do
      it 'ISBNの正規化(数字以外を削除)' do
        book = create(:book, isbn: '978-1-234-56789-0')
        expect(book.isbn).to eq('9781234567890')
      end
    end

    describe 'カスタムバリデーション' do
      it '売り切れの場合、在庫は0でなければならない' do
        book = build(:book, status: :sold_out, stock: 5)
        expect(book).not_to be_valid
        expect(book.errors[:stock]).to include('は売り切れのため0にする必要があります')
      end
    end

    describe 'Searchable concern' do
      let!(:rails_book) { create(:book, title: 'パーフェクトRails') }
      let!(:ruby_book) { create(:book, title: 'Ruby入門', author_name: 'Rubyist') }

      it 'タイトルで検索できる' do
        results = Book.search_by_keyword('Rails')
        expect(results).to include(rails_book)
        expect(results).not_to include(ruby_book)
      end

      it '著者名で検索できる' do 
        results = Book.search_by_keyword('Rubyist')
        expect(results).to include(ruby_book)
      end
    end
  end
end