class User < ApplicationRecord
  has_many :books, dependent: :destroy
  # has_many :events, dependent: :destroy  # TODO: Eventモデル作成後に有効化
  # has_many :participations, dependent: :destroy  # TODO: Participationモデル作成後に有効化

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
