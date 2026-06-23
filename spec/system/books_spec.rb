require 'rails_helper'

RSpec.describe "Books", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
  end

  describe '書籍一覧' do
    it '書籍が表示される' do
      book = create(:book, title: 'テスト書籍')
      visit books_path

      expect(page).to have_content('テスト書籍')
    end

    it '書籍を検索できる' do
      rails_book = create(:book, title: 'Rails本')
      ruby_book = create(:book, title: 'Ruby本')

      visit books_path
      fill_in 'keyword', with: 'Rails'
      click_button '🔍 検索'

      expect(page).to have_content('Rails本')
      expect(page).not_to have_content('Ruby本')

    end
  end

  describe '書籍詳細' do
    it '書籍の詳細情報が表示される' do
      book = create(:book, title: 'テスト書籍', author_name: 'テスト著者')
      visit book_path(book)

      expect(page).to have_content('テスト書籍')
      expect(page).to have_content('テスト著者')

    end
  end
end