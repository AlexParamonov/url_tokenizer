require_relative 'url_tokenizer/provider'

module UrlTokenizer
  Error = Class.new StandardError
  class << self
    def provider(name, key: nil)
      providers.fetch(name) do
        raise Error, "unknown provider '#{ name }'"
      end.new key
    end

    def register(provider_hash)
      providers.merge! provider_hash
    end

    private
    def providers
      @providers ||= {}
    end
  end
end
