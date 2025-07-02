class Conversation < ApplicationRecord
  belongs_to :user

  has_many :chats, dependent: :destroy
  has_many :messages, dependent: :destroy
  validates :name, :relationship, :ai_status, :ai_gender, presence: true

  def conversation_params
    params.require(:conversation).permit(:name, :relationship, :ai_status, :ai_gender, :ai_age, :description)
  end
end
