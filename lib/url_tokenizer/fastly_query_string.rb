require_relative 'fastly'
require 'rack'

module UrlTokenizer
  class FastlyQueryString < Fastly
    def call(input_url, **options)
      options = global_options.merge options
      uri = URI.parse input_url
      path = uri.path
      return if path.empty? || path == '/'

      expiration = expiration_date(options[:expires_in])

      token = digest [string_to_tokenize(uri), expiration].compact.join
      token = [expiration, token].compact.join '_'

      params = parse_query_string(uri).merge(token: token)

      uri.query = build_query params
      uri.to_s
    end

    def string_to_tokenize(uri)
      query = parse_query_string(uri)
      return uri.path[0..-(File.extname(uri.path).length + 1)] if query.key?('pub')

      File.dirname(uri.path)
    end

    private

    def parse_query_string(uri)
      return {} if uri.query.nil?

      Rack::Utils.parse_query(uri.query).tap do |params|
        params.delete('token')
      end
    end
  end
end
