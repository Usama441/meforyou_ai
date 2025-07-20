class TwilioController < ApplicationController
  # Skip CSRF protection for Twilio callbacks
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # Generate TwiML for voice verification
  def twiml
    code = params[:code]
    digits = code.to_s.chars.join(', ')

    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.say(message: 'Thank you for signing up with Me For You AI.', voice: 'alice')
      r.pause(length: 1)
      r.say(message: 'Your verification code is:', voice: 'alice')
      r.pause(length: 1)
      r.say(message: digits, voice: 'alice')
      r.pause(length: 1)
      r.say(message: 'I repeat. Your verification code is:', voice: 'alice')
      r.pause(length: 1)
      r.say(message: digits, voice: 'alice')
      r.pause(length: 1)
      r.say(message: 'Goodbye.', voice: 'alice')
    end

    render xml: response.to_s
  end
end
