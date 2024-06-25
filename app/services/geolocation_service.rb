require 'resolv'

class GeolocationService
  BASE_URL = 'http://api.ipstack.com'.freeze

  def initialize
    @conn = Faraday.new(url: BASE_URL) do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.params['access_key'] = ENV['IPSTACK_API_KEY']
    end
  end

  def fetch(ip_or_url)
    # Strip protocol if present
    ip_or_url = strip_protocol(ip_or_url)

    # Raise error if invalid format
    raise InvalidIpOrUrlError, "Invalid IP/URL format: #{ip_or_url}" unless valid_ip_or_url?(ip_or_url)

    response = @conn.get(ip_or_url)
    if response.success?
      JSON.parse(response.body)
    else
      raise Faraday::Error.new("HTTP request failed: #{response.status}")
    end
  end

  private

  def strip_protocol(ip_or_url)
    ip_or_url.gsub(%r{\Ahttps?://}, '')
  end

  def valid_ip_or_url?(ip_or_url)
    valid_ip?(ip_or_url) || valid_url?(ip_or_url)
  end

  def valid_ip?(ip)
    ip_regex_v4 = /\A(\d{1,3}\.){3}\d{1,3}\z/
    ip_regex_v6 = Resolv::IPv6::Regex

    if ip.match?(ip_regex_v4)
      ip.split('.').all? { |segment| segment.to_i.between?(0, 255) }
    elsif ip.match?(ip_regex_v6)
      true
    else
      false
    end
  end

  def valid_url?(url)
    !!(url =~ /\A[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}\z/) && resolvable?(url)
  end

  def resolvable?(url)
    Resolv.getaddress(url)
    true
  rescue Resolv::ResolvError
    false
  end
end