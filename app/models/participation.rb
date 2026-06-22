class Participation < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :comment, length: { maximum: 30 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :event_id, message: "はすでにこのイベントに参加しています" }
  validate :event_must_not_be_full
  validate :event_must_not_be_finished

  private

  def event_must_not_be_full
    return if event.blank?

    if event.full?
      errors.add(:base, "このイベントはすでに店員に達しています")
    end
  end

  def event_must_not_be_finished
    return if event.blank?

    if event.finished?
      errors.add(:base, "このイベントはすでに終了しています")
    end
  end

  

end
