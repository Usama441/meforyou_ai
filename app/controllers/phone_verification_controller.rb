class PhoneVerificationController < ApplicationController
  before_action :authenticate_user!

  def new
    @countries = CountryList.all
  end

  def create
    country_code = params[:country_code]
    phone_number = params[:phone_number]
    delivery_method = params[:delivery_method] || 'whatsapp'

    # Update user's phone number and country code
    if current_user.update(phone_number: phone_number, country_code: country_code)
      # Create verification code
      verification_code = current_user.create_verification_code('phone_verification')

      # Send verification code
      sms_service = SmsService.new(current_user)
      if sms_service.send_verification_code(verification_code, delivery_method)
        redirect_to verify_phone_path, notice: "Verification code sent via #{delivery_method.titleize}."
      else
        redirect_to new_phone_verification_path, alert: "Failed to send verification code. Please try again."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def verify
    # Show verification form
  end

  def confirm
    code = params[:code]

    if current_user.verify_code(code, 'phone_verification')
      redirect_to root_path, notice: "Phone number verified successfully!"
    else
      redirect_to verify_phone_path, alert: "Invalid or expired verification code."
    end
  end

  def resend
    delivery_method = params[:delivery_method] || 'whatsapp'

    # Create new verification code
    verification_code = current_user.create_verification_code('phone_verification')

    # Send verification code
    sms_service = SmsService.new(current_user)
    if sms_service.send_verification_code(verification_code, delivery_method)
      redirect_to verify_phone_path, notice: "New verification code sent via #{delivery_method.titleize}."
    else
      redirect_to verify_phone_path, alert: "Failed to send verification code. Please try again."
    end
  end
end
