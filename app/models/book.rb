class Book < ApplicationRecord
  belongs_to :user
  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres
  # has_many :events, dependent: :destroy  # TODO: Eventモデル作成後に有効化

  enum :status, {
    available: 0,
    sold_out: 1,
    discontinued: 2
  }

  validates :title, presence: true, length: { maximum: 200 }
  validates :isbn, presence: true, uniqueness: true, format:{
    with: /\A\d{13}\z/,
    message: "は13桁の数字で入力してください"
  }
  validates :author_name, presence: true, length: { maximum: 100 }
  validates :publisher, length: { maximum: 100 }, allow_blank: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :stock_must_be_zero_if_sold_out

  before_save :normalize_isbn
  after_create :log_hook_creation

  scope :available_books, -> { where(status: :available) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :in_stock, -> { where("stock > ?", 0) }
  scope :expensive, -> { where("price >= ?", 3000) }
  scope :recent, ->{ order(created_at: :desc) }

  private

  def stock_must_be_zero_if_sold_out
    if sold_out? && stock.to_i > 0
      errors.add(:stock, "は売り切れのため0にする必要があります")
    end
  end

  def normalize_isbn
    self.isbn = isbn.gsub(/\D/, '') if isbn.present?
  end

  def log_hook_creation
    Rails.logger.info "新しい書籍が登録されました: #{title} (ISBN: #{isbn})"
  end
end
