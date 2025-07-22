class RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        begin
          # Create verification code and send email
          verification_code = resource.create_verification_code
          VerificationMailer.verification_email(resource, verification_code).deliver_later
        rescue => e
          Rails.logger.error("Failed to create verification code: #{e.message}")
          # Continue with registration even if verification fails
          # We'll handle this in the verification flow
        end
      end
    end
    Rails.logger.debug "USER PARAMS: #{params[:user].inspect}"
    Rails.logger.debug "RESOURCE ERRORS: #{resource.errors.full_messages}"
  end

  def sign_up_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :dob,
      :gender,
      :email,
      :phone, # ✅ Add this
      :password,
      :password_confirmation
    )
  end

  protected

  def after_sign_up_path_for(resource)
    verification_path(email: resource.email)
  end
end
