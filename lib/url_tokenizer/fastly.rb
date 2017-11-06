require 'uri'
require 'openssl'
require_relative 'provider'

module UrlTokenizer
  class Fastly < Provider
    def call(input_url, **options)
      options = global_options.merge options
      uri = URI.parse input_url
      path = remove_old_token(uri.path)

      return if path.empty? || path == '/'

      expiration = expiration_date(options[:expires_in])
      dir = File.dirname(path)

      token = digest [path, expiration].compact.join
      token = [expiration, token].compact.join '_'

      # uri.path = ['/', token, path].join
      uri.query = URI.encode_www_form({token: token})
      uri.to_s
    end

    private

    def digest(string_to_sign)
      OpenSSL::HMAC.hexdigest('sha1', key, string_to_sign)
    end

    def remove_old_token(path)
      path.sub(/\d{10,}_\w{40}\/?/, '')
    end
  end
end
