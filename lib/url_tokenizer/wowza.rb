require 'uri'
require 'digest'
require 'base64'
require_relative 'provider'

module UrlTokenizer
  class Wowza < Provider
    def call(input_url, **options)
      options = global_options.merge options
      ignore_in_path = options.delete :ignore_in_path
      uri = URI.parse input_url

      folder_path = get_path uri, ignore_in_path
      return if folder_path.empty? || folder_path == '/'

      uri.query = encode_query folder_path, build_options(options)
      uri.to_s
    end

    private
    def get_path(uri, ignore_in_path)
      File.dirname(uri.path)[1..-1].tap do |path|
        path.gsub!(ignore_in_path, '') if ignore_in_path
      end
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
      pieces = build_query(provider_options).split('&')
      pieces << key

      query = pieces.compact.sort.join '&'

      string_to_tokenize = "#{ url }?#{ query }"

      build_query provider_options.merge(
        wowzatokenhash: digest(string_to_tokenize)
      )
    end
  end
end
