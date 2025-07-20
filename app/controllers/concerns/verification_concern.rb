module VerificationConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_email_verification, if: :verification_required?
  end

  private

  def require_email_verification
    return if current_user.email_verified?

    respond_to do |format|
      format.html { redirect_to verification_path, alert: 'Please verify your email address before continuing.' }
      format.json { render json: { error: 'Email verification required' }, status: :forbidden }
    end
  end

  def verification_required?
    user_signed_in? && !current_user.email_verified? && !verification_exempt_controller?
  end

  def verification_exempt_controller?
    controller_name == 'verification' || 
    controller_name == 'sessions' || 
    controller_name == 'registrations' || 
    controller_name == 'passwords'
  end
end
