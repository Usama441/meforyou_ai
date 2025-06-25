class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations (if any)
  has_many :chats, dependent: :destroy

  # Validations
  validates :relationship, presence: true
  validates :name, presence: true
  validates :ai_name, presence: true
end