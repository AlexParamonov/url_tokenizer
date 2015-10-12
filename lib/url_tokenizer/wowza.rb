require 'uri'
require 'digest'
require 'base64'
require_relative 'provider'

module UrlTokenizer
  class Wowza < Provider
    def call(input_url, **options)
      options = global_options.merge options
      uri = URI.parse input_url

      folder_path = get_path uri
      return if folder_path.empty? || folder_path == '/'

      uri.query = encode_query folder_path, build_options(options)
      uri.to_s
    end

    private
    def get_path(uri)
      File.dirname(uri.path)[1..-1] # remove leading / or .
    end

    def digest(url)
      sha256 = Digest::SHA256.digest url
      Base64.urlsafe_encode64(sha256)
    end

    def build_options(token_options)
      server_params = {
        wowzatokenendtime: expiration_date(token_options[:expires_in])
      }.delete_if { |k, v| v.nil? }

      server_params
    end

    def encode_query(url, provider_options)
      string_to_tokenize = [
        "#{ url }?#{ key }",
        build_query(provider_options)
      ].compact.join '&'

      build_query provider_options.merge(
        wowzatokenhash: digest(string_to_tokenize)
      )
    end
  end
end
