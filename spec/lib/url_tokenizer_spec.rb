require 'spec_helper'

describe UrlTokenizer do
  describe 'provider' do
    it 'returns a callable object' do
      subject.register dummy: spy
      expect(subject.provider :dummy).to respond_to :call
    end

    it 'returns registered provider' do
      provider = double :provider
      subject.register test_provider: provider
      expect(subject.provider :test_provider).to eq provider
    end

    it 'retrieves provider by symbol or string' do
      symbol_provider = double
      subject.register symbol: symbol_provider
      expect(subject.provider :symbol).to eq symbol_provider
      expect(subject.provider "symbol").to eq symbol_provider

      string_provider = double
      subject.register "string" => string_provider
      expect(subject.provider :string).to eq string_provider
      expect(subject.provider "string").to eq string_provider
    end

    describe 'when provider can not be found' do
      it 'raises an error' do
        expect do
          subject.provider :unknown
        end.to raise_error(described_class::Error)
      end
    end
  end
end
