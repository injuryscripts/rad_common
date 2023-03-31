class TwilioLog < ApplicationRecord
  belongs_to :from_user, class_name: 'User', optional: true
  belongs_to :to_user, class_name: 'User', optional: true

  scope :from_system, -> { where(from_user_id: nil) }
  scope :outgoing, -> { where(from_number: RadicalConfig.twilio_phone_number!) }
  scope :incoming, -> { where(to_number: RadicalConfig.twilio_phone_number!) }

  has_many_attached :attachments

  validates :attachments, content_type: %w[image/png image/jpeg image/jpg]

  def self.opt_out_message_sent?(to_number)
    TwilioLog.where(success: true, opt_out_message_sent: true, to_number: to_number).limit(1).any?
  end
end
