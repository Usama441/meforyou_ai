class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attr_accessor :contact_input

  # Associations (if any)
  has_many :chats, dependent: :destroy
  has_many :chat_sessions
  has_many :conversations, dependent: :destroy
  # Validations
  validates :relationship, presence: true
  validates :name, presence: true
  validates :ai_name, presence: true
  validate  :validate_contact_input
  before_validation :assign_contact_input
  GLOBAL_PHONE_REGEX = /\A\+?[1-9]\d{1,14}\z/

  validate :validate_global_phone

  def assign_contact_input
    return if contact_input.blank?

    if contact_input =~ URI::MailTo::EMAIL_REGEXP
      self.email = contact_input
    elsif contact_input =~ /\A(\+92|0)?3[0-9]{9}\z/ || contact_input =~ /\A\+?[1-9]\d{1,14}\z/
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

  def validate_global_phone
    if contact_input.present? && !(contact_input =~ GLOBAL_PHONE_REGEX)
      errors.add(:contact_input, "must be a valid international phone number")
    end
  end
end

