class RegistrationsController < Devise::RegistrationsController
  require 'net/http'
  require 'uri'
  require 'json'

  def create
    # Make sure we properly extract the reCAPTCHA response
    # recaptcha_response = params["g-recaptcha-response"]

    #unless verify_recaptcha_v2(recaptcha_response)
    #  build_resource(sign_up_params)
    #  resource.validate
    #  flash.now[:recaptcha_error] = "Please complete the reCAPTCHA verification."
    #  flash.now[:alert] = "reCAPTCHA verification failed. Please try again."
    #  respond_with_navigational(resource) { render :new }
    #  return
    #end

    super do |resource|
      if resource.persisted?
        begin
          verification_code = resource.create_verification_code
          VerificationMailer.verification_email(resource, verification_code).deliver_later
        rescue => e
          Rails.logger.error("Failed to create verification code: #{e.message}")
        end
      end
    end
  end

  private

  def verify_recaptcha_v2(response_token)
    secret_key = Rails.application.credentials.dig(:recaptcha, :secret_key) || ENV['RECAPTCHA_SECRET_KEY']
    return false unless response_token.present? && secret_key.present?

    uri = URI("https://www.google.com/recaptcha/api/siteverify")
    res = Net::HTTP.post_form(uri, {
      "secret" => secret_key,
      "response" => response_token
    })

    result = JSON.parse(res.body)
    Rails.logger.debug "RECAPTCHA V2 RESPONSE: #{result.inspect}"
    result["success"] == true
  end

  def sign_up_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :dob,
      :gender,
      :email,
      :phone,
      :password,
      :password_confirmation
    )
  end

  protected

  def after_sign_up_path_for(resource)
    verification_path(email: resource.email)
  end
end
