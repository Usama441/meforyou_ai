class Conversation < ApplicationRecord
  belongs_to :user

  has_many :chats, dependent: :destroy
  has_many :messages, dependent: :destroy
end
