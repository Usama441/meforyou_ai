# Recaptcha configuration
Recaptcha.configure do |config|
  config.site_key = Rails.application.credentials.dig(:recaptcha, :site_key) || ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = Rails.application.credentials.dig(:recaptcha, :secret_key) || ENV['RECAPTCHA_SECRET_KEY']
 end
# Configure reCAPTCHA
if defined?(Recaptcha)
  Recaptcha.configure do |config|
    config.site_key = Rails.application.credentials.dig(:recaptcha, :site_key) || ENV['RECAPTCHA_SITE_KEY']
    config.secret_key = Rails.application.credentials.dig(:recaptcha, :secret_key) || ENV['RECAPTCHA_SECRET_KEY']
  end
end