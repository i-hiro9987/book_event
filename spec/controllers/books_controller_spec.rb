require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let(:user) {create(:user)}
  let(:book) {create(:book, user: user)}

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    
    it '@booksに書籍一覧が格納される' do
      book1 = create(:book)
      book2 = create(:book)

      get :index
      expect(assigns(:books)).to match_array([book1, book2])
    end

    it 'キーワード検索が動作する' do
      rails_book = create(:book, title: 'Rails本')
      ruby_book = create(:book, title: 'Ruby本')

      get :index, params: {keyword: 'Rails'}
      expect(assigns(:books)).to include(rails_book)
      expect(assigns(:books)).not_to include(ruby_book)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: {id: book.id}
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    context 'ログインしている場合' do
      before { allow(controller).to receive(:current_user).and_return(user) }
      
      it 'returns http success' do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    context 'ログインしていない場合' do
      before { allow(controller).to receive(:current_user).and_return(nil) }
      
      it 'リダイレクトされる' do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
