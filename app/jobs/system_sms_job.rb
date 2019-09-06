class SystemSMSJob < ApplicationJob
  queue_as :default

  def perform(message, recipients, recipients_without_phone, current_user)
    errors = []
    from = RadicalTwilio.next_phone_number.presence || RadicalTwilio.single_twilio_number
    recipients.each do |user_id|
      user = User.find(user_id)

      begin
        RadicalRetry.perform_request do
          RadicalTwilio.send_sms(to: user.mobile_phone, message: message, from: from)
        end
      rescue Twilio::REST::RequestError
        errors << user.id
      end
    end

    return if errors.empty? && recipients_without_phone.empty?

    body = "These users did not receive a system SMS message due to system error: #{errors.join(', ')}\n"
    body += "These users did not receive a system SMS message because a mobile number was not present: #{recipients_without_phone.join(', ')}"
    RadbearMailer.simple_message(current_user, 'Error Sending System Message to Some Users', body).deliver_later
  end
end
