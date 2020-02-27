class RadicalRetry
  RESCUABLE_ERRORS = [Net::OpenTimeout, OpenURI::HTTPError, HTTPClient::ConnectTimeoutError, Errno::EPIPE, SocketError,
                      OpenSSL::SSL::SSLError, Errno::ENOENT, Errno::ECONNRESET, Twilio::REST::TwilioError].freeze

  class << self
    def perform_request(no_delay: false, retry_count: 5, additional_errors: [], &block)
      retries ||= retry_count
      block.call
    rescue *(additional_errors + RESCUABLE_ERRORS) => e
      raise e unless (retries -= 1).positive?

      exponential_pause(retries, no_delay)
      retry
    end
    alias try perform_request

    private

      WAIT_TIMES = [2, 4, 8, 16, 32, 64].freeze

      def exponential_pause(attempts, no_delay)
        return 0 if no_delay

        seconds = WAIT_TIMES[attempts - 1] || 64
        sleep(seconds)
      end
  end
end
