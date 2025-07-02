class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations (if any)
  has_many :chats, dependent: :destroy
  has_many :chat_sessions
  has_many :conversations, dependent: :destroy
  # Validations
  validates :relationship, presence: true
  validates :name, presence: true
  validates :ai_name, presence: true
end