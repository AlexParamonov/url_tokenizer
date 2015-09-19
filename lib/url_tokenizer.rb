require_relative 'url_tokenizer/provider'
require 'facets/hash/symbolize_keys'

module UrlTokenizer
  Error = Class.new StandardError
  class << self
    def provider(name)
      providers.fetch(name.to_sym) do
        raise Error, "unknown provider '#{ name }'"
      end
    end

    def register(provider_hash)
      providers.merge! provider_hash.symbolize_keys
    end

    private
    def providers
      @providers ||= {}
    end
  end
end
