class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :chat_session, optional: true
  belongs_to :conversation


end
