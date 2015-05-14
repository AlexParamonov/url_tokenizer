require 'spec_helper'
require 'url_tokenizer/provider/limelight'

describe UrlTokenizer::Provider::Limelight do
  subject { described_class.new key }
  let(:key) { "secret" }
  let(:url) { 'http://liveplay3.malimarserver.com/limelight/testtokenstream/playlist.m3u8' }

  describe 'when url have the query string' do
    let(:url) { 'http://liveplay3.malimarserver.com/limelight/testtokenstream/playlist.m3u8?foo=bar' }

    it 'does not add question mark' do
      expect(subject.call(url).count('?')).to eq 1
    end
  end

  describe 'when url have provider parameters' do
    let(:url) { 'http://liveplay3.malimarserver.com/limelight/testtokenstream/playlist.m3u8?e=12345' }

    it 'ignores and overwrites them' do
      expect(subject.call url).not_to include 'e=12345'
      expect(subject.call url).to match /e=\d+\&/
    end
  end

  it "adds h parameter" do
    expect(subject.call url).to match /&h=[a-z0-9]+\z/
  end
end
