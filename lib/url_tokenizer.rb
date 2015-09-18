require_relative 'url_tokenizer/provider'

module UrlTokenizer
  Error = Class.new StandardError
  class << self
    def provider(name)
      providers.fetch(name.to_sym) do
        raise Error, "unknown provider '#{ name }'"
      end
    end

    def register(provider_hash)
      providers.merge! symbolize_keys(provider_hash)
    end

    private
    def providers
      @providers ||= {}
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
