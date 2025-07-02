class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attr_accessor :contact_input

  # Associations
  has_many :chats, dependent: :destroy
  has_many :chat_sessions
  has_many :conversations, dependent: :destroy

  # Validations
  validate :validate_contact_input
  before_validation :assign_contact_input

  def assign_contact_input
    return if contact_input.blank?

    if contact_input =~ URI::MailTo::EMAIL_REGEXP
      self.email = contact_input
    elsif contact_input =~ /\A(\+92|0)?3[0-9]{9}\z/ || contact_input =~ /\A\+?[1-9]\d{9,14}\z/
      self.phone = normalize_phone(contact_input)
    else
      errors.add(:contact_input, "must be a valid email or phone number")
    end
  end

  def normalize_phone(input)
    input.gsub(/\D/, '').tap do |digits|
      digits.prepend('+') unless input.start_with?('+')
    end
  end

  def validate_contact_input
    input = contact_input.to_s.strip
    if input.blank?
      errors.add(:contact_input, "can't be blank")
    elsif input.include?("@")
      unless input =~ URI::MailTo::EMAIL_REGEXP
        errors.add(:contact_input, "must be a valid email")
      end
    else
      unless input.match?(/\A(\+92|0)?3[0-9]{9}\z/) || input.match?(/\A\+?[1-9]\d{9,14}\z/)
        errors.add(:contact_input, "must be a valid phone number")
      end
    end
  end
end
