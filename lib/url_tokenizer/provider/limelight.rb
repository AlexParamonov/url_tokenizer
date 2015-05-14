module UrlTokenizer
  module Provider
    class Limelight
      def initialize(key)
        @key = key
      end

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
      attr_reader :key


      def build_options(token_options, url:, uri:)
        {
          **url_params(uri),
          p: url.length,
          e: expiration_date(token_options)
        }
      end

      def url_params(uri)
        return {} if uri.query.nil?

        symbolize_keys(CGI.parse(uri.query)).tap do |params|
          params.delete :h
          params.delete :e
          params.delete :p
        end
      end

      def expiration_date(options)
        Time.now.utc.to_i + options[:expire_in].to_i
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
end
