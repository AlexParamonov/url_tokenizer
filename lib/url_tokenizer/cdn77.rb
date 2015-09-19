require 'uri'
require 'digest'
require 'base64'
require_relative 'provider'

module UrlTokenizer
  class CDN77 < Provider
    def call(input_url, **options)
      options = global_options.merge options
      uri = URI.parse input_url
      path = uri.path
      return if path.empty? || path == '/'

      expiration = expiration_date(options[:expires_in])
      token = digest [expiration, path, key].compact.join
      token = [token, expiration].compact.join ','

      uri.query = build_query secure: token
      uri.to_s
    end

    private
    def expiration_date(expires_in)
      Time.now.utc.to_i + expires_in.to_i if expires_in
    end

    def digest(url)
      md5 = Digest::MD5.digest url
      Base64.urlsafe_encode64(md5)
    end

    def build_query(provider_options)
      provider_options.reduce([]) do |query, (key, value)|
        query << "#{ key }=#{ value }"
      end.join '&'
    end
  end
end
