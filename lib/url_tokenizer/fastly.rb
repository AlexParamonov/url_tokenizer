require 'uri'
require 'openssl'
require_relative 'provider'

module UrlTokenizer
  class Fastly < Provider
    def call(input_url, **options)
      options = global_options.merge options
      uri = URI.parse input_url
      path = uri.path
      return if path.empty? || path == '/'

      expiration = expiration_date(options[:expires_in])
      dir = File.dirname(path)

      token = digest [dir, expiration].compact.join
      token = [expiration, token].compact.join '_'

      uri.path = ['/', token, path].join
      uri.to_s
    end

    private
    def digest(string_to_sign)
      OpenSSL::HMAC.hexdigest('sha1', key, string_to_sign)
    end
  end
end
