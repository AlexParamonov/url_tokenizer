require 'rack'
require 'uri'
require 'openssl'
require 'base64'
require_relative 'provider'

module UrlTokenizer
  class Cloudflare < Provider
    def call(input_url, **options)
      options = global_options.merge options
      uri = URI.parse input_url
      path = uri.path
      return if path.empty? || path == '/'

      expiration = expiration_date(options[:expires_in])

      string_to_digest = [string_to_tokenize(uri), expiration].compact.join

      token = digest string_to_digest
      token = [expiration, token].compact.join '_'

      params = parse_query_string(uri).merge(verify: token)

      uri.query = build_query params
      uri.to_s
    end

    def string_to_tokenize(uri)
      File.dirname(uri.path)
    end

    private

    def parse_query_string(uri)
      return {} if uri.query.nil?

      Rack::Utils.parse_query(uri.query).tap do |params|
        params.delete('verify')
      end
    end

    def digest(string_to_sign)
      sha256 = OpenSSL::HMAC.digest('sha256', key, string_to_sign)

      CGI.escape(
        Base64.encode64(sha256).strip
      )
    end
  end
end
