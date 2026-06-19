class User < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :participations, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
