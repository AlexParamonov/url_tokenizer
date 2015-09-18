require 'uri'
require 'cgi'
require 'digest'
require_relative 'provider'

module UrlTokenizer
  class Limelight < Provider
    PARAMS = %i[e h p cf cd]

    def call(input_url, **options)
      uri = URI.parse input_url
      folder = File.dirname input_url

      provider_options = build_options options, url: folder, uri: uri

      query_string = URI.encode_www_form provider_options
      url_to_encode = [folder, query_string].join '?'

      provider_options[:h] = digest url_to_encode

      uri.query = URI.encode_www_form provider_options
      uri.to_s
    end

    private
    def build_options(token_options, url:, uri:)
      server_params = {
        p: url.length,
        e: expiration_date(token_options[:expires_in]),
      }.delete_if { |k, v| v.nil? }

      cookie_params = {
        cd: token_options[:cd],
        cf: expiration_date(token_options[:cf]),
      }.delete_if { |k, v| v.nil? }

      server_params.delete :e if cookie_params.any?

      url_params(uri)
        .merge(server_params)
        .merge(cookie_params)
    end

    def url_params(uri)
      return {} if uri.query.nil?

      symbolize_keys(CGI.parse(uri.query)).tap do |params|
        PARAMS.each do |param|
          params.delete param
        end
      end
    end

    def expiration_date(expires_in)
      Time.now.utc.to_i + expires_in.to_i if expires_in
    end

    def digest(url)
      Digest::MD5.hexdigest "#{ key }#{ url }"
    end

    def symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end
  end
end
