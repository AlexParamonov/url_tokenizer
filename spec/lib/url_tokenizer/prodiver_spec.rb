require 'spec_helper'

describe UrlTokenizer::Provider do
  subject { described_class.new key }
  let(:key) { "secret key" }

  it 'requires the key' do
    expect do
      described_class.new
    end.to raise_error ArgumentError

    expect do
      described_class.new key
    end.not_to raise_error
  end

  it 'responds to #call' do
    expect(subject).to respond_to :call
  end

  describe "#call" do
    it 'requires the url' do
      expect do
        subject.call
      end.to raise_error ArgumentError

      expect do
        subject.call 'http://example.com'
      end.not_to raise_error
    end
  end
end
