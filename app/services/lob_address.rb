class LobAddress
  attr_reader :address_args

  def initialize(address_args)
    @address_args = parse_address_args(address_args)
  end

  def call
    unformatted_result = JSON.parse(api_result).presence || {}
    LobResult.new(unformatted_result, zip4_provided?)
  end

  private

    def parse_address_args(address_args)
      if address_args[:zipcode].present?
        numeric_code = address_args[:zipcode].scan(/\d+/).join
        numeric_code = '' if numeric_code.length < 5
        address_args = address_args.merge(zipcode: numeric_code)
      end

      address_args
    end

    def zip4_provided?
      address_args[:zipcode].present? && address_args[:zipcode].size == 9
    end

    def api_result
      @api_result ||=
        Rails.cache.fetch(cache_key, expires_in: 1.day) do
          lob = Lob::Client.new(api_key: RadicalConfig.lob_key!)
          log_request_made

          RadicalRetry.perform_request(additional_errors: [Lob::InvalidRequestError]) {
            lob.us_verifications.verify(lob_args)
          }.to_json
        end
    end

    def lob_args
      { primary_line: address_args[:address_1],
        secondary_line: address_args[:address_2],
        city: address_args[:city],
        state: address_args[:state],
        zip_code: address_args[:zipcode] }
    end

    def cache_key
      address_args.sort.map(&:last).join.parameterize
    end

    def log_request_made
      Company.main.increment! :address_requests_made
    end
end