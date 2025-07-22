class UserMailer < ApplicationMailer
  default from: ENV["GMAIL_USERNAME"]

  def welcome_email(user)
    @user = user
    @login_url = "http://localhost:3000/login"
    mail(to: @user.email, subject: "Welcome to Our App!")
  end

  def verification_email(user, code)
    @user = user
    @code = code
    mail(to: @user.email, subject: "Your Verification Code")
  end

  def reset_password_email(user, token)
    @user = user
    @reset_url = "http://localhost:3000/password_reset/#{token}"
    mail(to: @user.email, subject: "Reset Your Password")
  end
end
