class VerificationController < ApplicationController
  before_action :authenticate_user!

  def index
    # Show verification form
  end

  def send_code
    code = current_user.create_verification_code
    UserMailer.verification_email(current_user, code.code).deliver_now
    redirect_to verification_path, notice: "Verification code sent to your email."
  end

  def verify
    input_code = params[:code]
    if current_user.verification_codes.where(code: input_code).order(created_at: :desc).exists?
      current_user.update(email_verified: true)
      redirect_to root_path, notice: "Email verified successfully."
    else
      redirect_to verification_path, alert: "Invalid code."
    end
  end

  def resend_code
    code = current_user.create_verification_code
    UserMailer.verification_email(current_user, code.code).deliver_now
    redirect_to verification_path, notice: "New code sent."
  end
end
