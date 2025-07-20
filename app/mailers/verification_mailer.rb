class VerificationMailer < ApplicationMailer
  default from: 'noreply@meforyou.ai'

  def verification_email(user, verification_code)
    @user = user
    @verification_code = verification_code
    @verification_url = verify_url(user_id: user.id, code: verification_code.code)

    mail(
      to: user.email,
      subject: 'MeForYou AI - Verify Your Email'
    )
  end
end
