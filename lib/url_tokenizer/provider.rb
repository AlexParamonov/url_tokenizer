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
  end
end
