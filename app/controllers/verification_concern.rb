module VerificationConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_verification, if: :verification_required?
  end

  private

  def require_verification
    if !current_user.email_verified?
      respond_to do |format|
        format.html { redirect_to verification_path, alert: 'Please verify your email address before continuing.' }
        format.json { render json: { error: 'Email verification required' }, status: :forbidden }
      end
    elsif current_user.phone_number.present? && !current_user.phone_verified?
      respond_to do |format|
        format.html { redirect_to verify_phone_path, alert: 'Please verify your phone number before continuing.' }
        format.json { render json: { error: 'Phone verification required' }, status: :forbidden }
      end
    end
  end

  def verification_required?
    return false unless user_signed_in?

    needs_verification = false

    # Email verification is always required
    needs_verification = true if !current_user.email_verified?

    # Phone verification is required only if a phone number is present
    if current_user.phone_number.present? && !current_user.phone_verified?
      needs_verification = true
    end

    needs_verification && !verification_exempt_controller?
  end

  def verification_exempt_controller?
    controller_name == 'verification' || 
    controller_name == 'phone_verification' ||
    controller_name == 'sessions' || 
    controller_name == 'registrations' || 
    controller_name == 'passwords' ||
    controller_name == 'twilio'
  end
end
