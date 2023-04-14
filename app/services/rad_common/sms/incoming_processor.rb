module RadCommon
  module SMS
    class IncomingProcessor
      attr_reader :matched_processor

      include Utilities

      COMMAND_PROCESSORS = [OptOut, OptIn].freeze

      def initialize(params)
        @params = params
        @incoming_message = params[:Body]
        @attachments = get_attachments
        @phone_number = Utilities.format_twilio_number(params[:From])
        @command_results = nil
        @sms_reply = nil
        @reply_command = cleanup_command(@incoming_message)
        @matched_processor = nil
      end

      def process
        @command_results = mms? ? process_mms : process_sms
        log_sms!
        @sms_reply = @command_results.sms_reply
        return unless @command_results.reply

        after_process
      end

      private

        def process_sms
          @matched_processor = command_processors.find { |processor| processor.matches?(@reply_command) }
          if @matched_processor
            processor = @matched_processor.new(incoming_message: @reply_command,
                                               phone_number: @phone_number,
                                               sms_users: sms_users,
                                               locale: locale)
            return processor.process
          end

          CommandResults.new(command_matched: false, incoming_message: @incoming_message)
        end

        def process_mms
          log_mms!

          CommandResults.new sms_reply: (@log.persisted? ? nil : translate_reply(:communication_mms_failure)),
                             reply: @log.new_record?,
                             incoming_message: @incoming_message.presence || 'MMS',
                             command_matched: false
        end

        def mms?
          @params['MessageSid']&.starts_with? 'M'
        end

        def sms_users
          @sms_users ||= []
        end

        def locale
          'en'
        end

        def command_processors
          COMMAND_PROCESSORS
        end

        def after_process
          send_reply
        end

        def cleanup_command(command)
          command.gsub(/["']/, '').upcase.strip
        end

        def log_sms!
          return if mms?

          @log = TwilioLog.create! to_number: RadicalConfig.twilio_phone_number!,
                                   from_number: @phone_number,
                                   message: @incoming_message
        end

        def get_attachments
          return [] unless mms?

          (0..(@params['NumMedia'].to_i - 1)).map do |counter|
            RadicalRetry.perform_request(retry_count: 2) do
              URI.open(@params["MediaUrl#{counter}"])
            end
          end.compact
        end

        def log_mms!
          return if @attachments.blank?

          @log = TwilioLog.new to_number: RadicalConfig.twilio_phone_number!,
                               from_number: @phone_number,
                               message: @incoming_message.presence || 'MMS'

          @attachments.each do |file|
            @log.media_url = file.base_uri.to_s
            next unless file.respond_to? :path

            @log.attachments.attach io: file, filename: File.basename(file.path)
          end

          @log.attachments = [] if @log.errors.messages.has_key?(:attachments)
          @log.tap(&:save)
        end

        def translate_reply(sms_reply_key, params = {})
          params.merge!(locale: locale)
          I18n.t(sms_reply_key, **params)
        end
    end
  end
end
