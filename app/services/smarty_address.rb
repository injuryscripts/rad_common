class SmartyAddress
  attr_reader :address_args

  def initialize(address_args)
    @address_args = parse_address_args(address_args)
  end

  def call
    unformatted_result = JSON.parse(api_result).presence || {}
    SmartyResult.new(unformatted_result)
  end

  private

    def parse_address_args(address_args)
      if address_args[:zip_code].present?
        numeric_code = address_args[:zip_code].scan(/\d+/).join
        numeric_code = '' if numeric_code.length < 5
        address_args = address_args.merge(zip_code: numeric_code)
      end

      address_args
    end

    def api_result
      @api_result ||=
        Rails.cache.fetch(cache_key, expires_in: 1.day) do
          lookup = SmartyStreets::USStreet::Lookup.new
          lookup.street = address_args[:primary_line]
          lookup.secondary = address_args[:secondary_line]
          lookup.city = address_args[:city]
          lookup.state = address_args[:state]
          lookup.zipcode = address_args[:zip_code]
          lookup.candidates = 1 # TODO: investigate this

          log_request_made

          RadicalRetry.perform_request(additional_errors: [SmartyStreets::SmartyError]) {
            client.send_lookup(lookup)
          }.to_json
        end
    end

    def cache_key
      address_args.sort.map(&:last).join.parameterize
    end

    def log_request_made
      Company.main.increment! :address_requests_made
    end

    def client
      SmartyStreets::ClientBuilder.new(credentials).with_licenses(['us-core-cloud']).build_us_street_api_client
    end

    def credentials
      SmartyStreets::StaticCredentials.new(RadicalConfig.smarty_auth_id!, RadicalConfig.smarty_auth_token!)
    end
end
