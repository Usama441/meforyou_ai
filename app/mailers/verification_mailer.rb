class VerificationMailer < ApplicationMailer
  def verification_email(user, code)
    @user = user
    @code = code
    mail(to: @user.email, subject: 'Your Verification Code')
  end
end
