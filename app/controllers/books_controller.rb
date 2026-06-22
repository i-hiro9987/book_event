class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = Book.includes(:user, :genres).recent.page(params[:page])
  end

  def show
  end

  def new
    @book = Book.new
  end

  def create
    @book = current_user.books.new(book_params)

    if @book.save
      redirect_to @book, notice: "書籍を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "書籍を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_url, notice: '書籍を削除しました'
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(
      :title, :isbn, :author_name, :publisher, :price, :stock, :status, genre_ids: []
    )
  end

  def current_user
    @current_user ||= User.first || User.create!(name: '仮ユーザ', email: 'temp@example.com')
  end

  helper_method :current_user
end
