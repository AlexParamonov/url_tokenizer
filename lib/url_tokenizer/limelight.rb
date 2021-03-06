require 'uri'
require 'cgi'
require 'digest'
require_relative 'provider'
require 'facets/hash/symbolize_keys'

module UrlTokenizer
  class Limelight < Provider
    PARAMS = %i[e h p cf cd]

    def call(input_url, **options)
      options = global_options.merge options
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

      token_options.delete :ip if global_options[:ip] == false
      filtering_params = {
        ip: token_options[:ip]
      }.delete_if { |k, v| v.nil? }

      server_params.delete :e if cookie_params.any?

      url_params(uri)
        .merge(server_params)
        .merge(cookie_params)
        .merge(filtering_params)
    end

    def url_params(uri)
      return {} if uri.query.nil?

      CGI.parse(uri.query).symbolize_keys.tap do |params|
        PARAMS.each do |param|
          params.delete param
        end
      end
    end

    def digest(url)
      Digest::MD5.hexdigest "#{ key }#{ url }"
    end
  end
end
