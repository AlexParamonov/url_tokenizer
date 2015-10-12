module UrlTokenizer
  class Provider
    def initialize(key, **global_options)
      @key = key
      @global_options = global_options
    end

    def call(input_url, **options)
      input_url
    end

    private
    attr_reader :key, :global_options

    def build_query(provider_options)
      provider_options.reduce([]) do |query, (key, value)|
        query << "#{ key }=#{ value }"
      end.join '&'
    end

    def expiration_date(expires_in)
      Time.now.utc.to_i + expires_in.to_i if expires_in
    end
  end
end
