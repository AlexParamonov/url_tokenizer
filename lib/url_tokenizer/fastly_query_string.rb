require_relative 'fastly'

module UrlTokenizer
  class FastlyQueryString < Fastly
    def call(input_url, **options)
      options = global_options.merge options
      uri = URI.parse input_url
      path = uri.path
      return if path.empty? || path == '/'

      expiration = expiration_date(options[:expires_in])
      dir = File.dirname(path)

      token = digest [dir, expiration].compact.join
      token = [expiration, token].compact.join '_'

      uri.query = build_query token: token
      uri.to_s
    end
  end
end
