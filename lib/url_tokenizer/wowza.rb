require 'uri'
require 'digest'
require 'base64'
require_relative 'provider'

module UrlTokenizer
  class Wowza < Provider
    def call(input_url, **options)
      options = global_options.merge options
      uri = URI.parse input_url
      path = uri.path
      return if path.empty? || path == '/'

      uri.query = nil
      token = digest [uri.to_s, key].compact.join '?'
      uri.query = build_query wowzatokenhash: token
      uri.to_s
    end

    private
    def digest(url)
      md5 = Digest::SHA256.digest url
      Base64.urlsafe_encode64(md5)
    end
  end
end
