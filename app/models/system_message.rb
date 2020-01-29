class SystemMessage < ApplicationRecord
  belongs_to :user

  enum send_to: { internal_users: 0, client_users: 1, all_users: 2, preview: 3 }
  enum message_type: { email: 0, sms: 1 }

  scope :recent_first, -> { order(created_at: :desc) }

  has_rich_text :email_message_body

  # validates :message, presence: true, if: :sms?
  # validates :email_message_body, presence: true, if: :email?

  def to_s
    "System Message from #{user}"
  end

  def sms_message=(value)
    self.message = value if sms?
  end

  def sms_message
    message if last_message&.sms?
  end

  def self.recent_or_new(user)
    last_message = user.system_messages.recent_first.first
    return SystemMessage.new if last_message.blank?

    SystemMessage.new(send_to: last_message.send_to,
                      message: last_message.message,
                      message_type: last_message.message_type)
  end

  def recipients
    return [user] if preview?

    users = User.active

    users = users.internal if internal_users?
    users = users.external if client_users?

    users
  end

  def html_message
    message ? message.html_safe : email_message_body
  end

  def send!
    if email?
      recipients.each do |user|
        RadbearMailer.simple_message(user, "Important Message From #{I18n.t(:app_name)}", email_message_body, do_not_format: true).deliver_later
      end
    else
      SystemSMSJob.perform_later(message, recipients.map(&:id), user)
    end
  end

  private

    def last_message
      SystemMessage.recent_first.first
    end
end
