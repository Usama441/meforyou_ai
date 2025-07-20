# Twilio API configuration
# In production, replace these with your actual Twilio credentials

if Rails.env.production? && defined?(Twilio)
  Twilio.configure do |config|
    config.account_sid = ENV['TWILIO_ACCOUNT_SID']
    config.auth_token = ENV['TWILIO_AUTH_TOKEN']
  end

  # Add environment variables to .env file:
  # TWILIO_ACCOUNT_SID=your_account_sid
  # TWILIO_AUTH_TOKEN=your_auth_token
  # TWILIO_PHONE_NUMBER=your_twilio_phone_number
  # TWILIO_WHATSAPP_NUMBER=your_twilio_whatsapp_number (with country code)
  # HOST=your_application_host (for TwiML callbacks)
end
