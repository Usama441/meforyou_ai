class VerificationController < ApplicationController
  before_action :authenticate_user!, except: [:verify]

  def send_code
    # Create a verification code
    verification_code = current_user.create_verification_code

    # Send the verification email
    VerificationMailer.verification_email(current_user, verification_code).deliver_now

    respond_to do |format|
      format.html { redirect_to verification_path, notice: 'Verification code sent to your email.' }
      format.json { render json: { message: 'Verification code sent.' }, status: :ok }
    end
  rescue => e
    Rails.logger.error("Error sending verification code: #{e.message}")
    respond_to do |format|
      format.html { redirect_to verification_path, alert: 'Error sending verification code. Please try again.' }
      format.json { render json: { error: 'Failed to send verification code' }, status: :unprocessable_entity }
    end
  end

  def verify
    user = User.find_by(id: params[:user_id])

    # Handle case where no verification code exists
    if user.nil?
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Invalid verification request.' }
        format.json { render json: { error: 'Invalid user' }, status: :unprocessable_entity }
      end
      return
    end

    if user.verify_code(params[:code])
      # If user is not signed in, sign them in
      sign_in(user) unless current_user

      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Your email has been verified!' }
        format.json { render json: { message: 'Email verified successfully' }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to verification_path, alert: 'Invalid or expired verification code.' }
        format.json { render json: { error: 'Invalid verification code' }, status: :unprocessable_entity }
      end
    end
  end

  def index
    redirect_to root_path if current_user.email_verified?
  end

  def resend_code
    # Create a new verification code
    verification_code = current_user.create_verification_code

    # Send the verification email
    VerificationMailer.verification_email(current_user, verification_code).deliver_now

    redirect_to verification_path, notice: 'A new verification code has been sent to your email.'
  rescue => e
    Rails.logger.error("Error resending verification code: #{e.message}")
    redirect_to verification_path, alert: 'Error sending verification code. Please try again.'
  end
end
