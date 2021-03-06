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
    def digest(url)
      md5 = Digest::MD5.digest url
      Base64.urlsafe_encode64(md5)
    end
  end
end
