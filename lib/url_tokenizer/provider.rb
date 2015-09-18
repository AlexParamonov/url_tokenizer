module UrlTokenizer
  class Provider
    def initialize(key, **provider_options)
      @key = key
      @provider_options = provider_options
    end

    def call(input_url, **options)
      input_url
    end

    private
    attr_reader :key, :provider_options
  end
end
