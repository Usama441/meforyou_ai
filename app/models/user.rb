class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attr_accessor :contact_input

  # Associations
  has_many :chats, dependent: :destroy
  has_many :chat_sessions
  has_many :conversations, dependent: :destroy
  has_many :verification_codes, dependent: :destroy

  # Virtual validations
  before_validation :assign_contact_input
  validate :email_or_phone_present
  validate :validate_contact_input

  # Conditional email/phone validations
  validates :email, uniqueness: true, allow_blank: true
  validates :phone, uniqueness: true, allow_blank: true

  # Phone formatting
  before_validation :format_phone_number, if: -> { phone_number_changed? }

  validates :phone_number, format: {
    with: /\A\+?[0-9\s\-\(\)]+\z/,
    message: "only allows numbers, spaces, and +() characters"
  }, allow_blank: true

  validates :phone_number, uniqueness: true, if: -> { phone_number.present? }

  attribute :email_verified, :boolean, default: false
  attribute :phone_verified, :boolean, default: false

  # =========================
  # 🧠 METHODS
  # =========================

  def email_or_phone_present
    if email.blank? && phone.blank?
      errors.add(:base, "Either email or phone must be present")
    end
  end

  # app/models/user.rb

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

  def validate_contact_input
    return if contact_input.blank?

    if contact_input.include?("@")
      errors.add(:contact_input, "must be a valid email") unless contact_input =~ URI::MailTo::EMAIL_REGEXP
    else
      unless contact_input.match?(/\A(\+92|0)?3[0-9]{9}\z/) || contact_input.match?(/\A\+?[1-9]\d{9,14}\z/)
        errors.add(:contact_input, "must be a valid phone number")
      end
    end
  end

  def normalize_phone(input)
    digits = input.gsub(/\D/, '')
    input.start_with?('+') ? "+#{digits}" : "+#{digits}"
  end

  def full_phone_number
    return nil if phone_number.blank?
    country_code.present? ? "#{country_code}#{phone_number}" : phone_number
  end

  def verified?
    email_verified? && (phone_number.blank? || phone_verified?)
  end

  def create_verification_code(type = 'email_verification')
    verification_codes.active.where(code_type: type).update_all(used: true)
    verification_codes.create(code_type: type)
  end

  def verify_code(input_code, type = 'email_verification')
    code = verification_codes.active.where(code_type: type).order(created_at: :desc).first
    return false unless code&.valid_code?(input_code)

    code.mark_as_used!

    case type
    when 'email_verification'
      update(email_verified: true)
    when 'phone_verification'
      update(phone_verified: true)
    end

    true
  end

  private

  def format_phone_number
    return if phone_number.blank?
    self.phone_number = phone_number.gsub(/[\s\-\(\)]/, '').gsub(/^\+/, '')
  end
end
