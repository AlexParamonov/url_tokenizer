require 'spec_helper'

describe UrlTokenizer do
  describe 'provider' do
    it 'returns a callable object' do
      subject.register dummy: spy
      expect(subject.provider :dummy).to respond_to :call
    end

    it 'initialize provider' do
      provider_class = spy
      subject.register spy: provider_class
      expect(provider_class).to receive(:new)
      subject.provider :spy
    end

    describe 'when provider can not be found' do
      it 'raises an error' do
        expect do
          subject.provider :unknown
        end.to raise_error(described_class::Error)
      end
    end
  end

  describe 'register' do
    let(:test_provider) { spy :test_provider }

    describe 'with symbol key' do
      before do
        subject.register test: test_provider
      end

      it 'can be retrieved by symbol key' do
        subject.provider(:test).to eq test_provider
      end

      it 'can be retrieved by string key' do
        subject.provider('test').to eq test_provider
      end
    end

    describe 'with string key' do
      before do
        subject.register 'test' => test_provider
      end

      it 'can be retrieved by symbol key' do
        subject.provider(:test).to eq test_provider
      end

      it 'can be retrieved by string key' do
        subject.provider('test').to eq test_provider
      end
    end
  end
end
