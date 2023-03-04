module Users
  class DeviseTwilioVerifyController < Devise::DeviseController
    def GET_verify_twilio
      if @resource.twilio_verify_sms?
        verify = RadicalTwilio.send_verify_sms(@resource.mobile_phone)

        if verify.status == 'pending'
          flash[:info] = 'A verification token has been texted to you.'
        else
          flash[:alert] = 'The verification code failed to send. Please click "Resend Text".'
        end
      end

      super
    end
  end
end
