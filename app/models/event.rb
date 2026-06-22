class Event < ApplicationRecord
  belongs_to :book
  belongs_to :user

  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user

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

  scope :upcoming, -> { where("start_at >= ?", Time.current).order(start_at: :asc) }
  scope :past, -> { where("start_at < ?", Time.current).order(start_at: :desc) }
  scope :by_book, -> (book_id) { where(book_id: book_id) }
  scope :recent, -> { order(created_at: :desc) }

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
