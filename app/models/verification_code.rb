class VerificationCode < ApplicationRecord
  belongs_to :user

  validates :code, presence: true, length: { is: 6 }
  validates :expires_at, presence: true

  # Set default values
  attribute :used, :boolean, default: false

  scope :active, -> { where("expires_at > ? AND used = ?", Time.current, false) }

  before_validation :generate_code, on: :create
  before_validation :set_expiration, on: :create

  def expired?
    expires_at <= Time.current
  end

  def valid_code?(input_code)
    !expired? && !used && code == input_code
  end

  def mark_as_used!
    update(used: true)
  end

  private

  def generate_code
    self.code ||= SecureRandom.random_number(100000..999999).to_s
  end

  def set_expiration
    self.expires_at ||= 30.minutes.from_now
  end
end
