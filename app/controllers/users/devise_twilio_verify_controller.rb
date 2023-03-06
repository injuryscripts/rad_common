module Users
  class DeviseTwilioVerifyController < Devise::DeviseTwilioVerifyController
    def GET_verify_twilio_verify
      if @resource.twilio_verify_sms?
        if RadicalTwilio.send_verify_sms(@resource.mobile_phone)
          flash[:info] = 'A verification token has been texted to you.'
        else
          flash[:alert] = 'The verification code failed to send. Please click "Resend Text".'
        end
      end

      super
    end
  end
end
