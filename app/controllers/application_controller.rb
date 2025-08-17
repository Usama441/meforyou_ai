class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    added_attrs = [
      :first_name,
      :last_name,
      :dob,
      :gender,
      :contact_input,
      :email,
      :password,
      :password_confirmation,
      :verification_method   # 👈 yeh add karna zaroori hai
    ]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end
  def after_sign_in_path_for(resource)
    chat_path  # or root_path if chat is at root
  end


  def after_sign_up_path_for(resource_or_scope)
    return new_user_session_path
  end
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def ensure_verified_user!
    return if current_user&.verified?

    redirect_to verification_path, alert: "Please verify your email before continuing."
  end
end
