require 'spec_helper'

describe UrlTokenizer do
  it 'has a version number' do
    expect(UrlTokenizer::VERSION).not_to be nil
  end

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
end
