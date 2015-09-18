require 'spec_helper'
require 'url_tokenizer/limelight'

describe UrlTokenizer::Limelight do
  subject { described_class.new key }
  let(:key) { "secret" }
  let(:url) { url_with_params }

  describe 'when url have the query string' do
    let(:url) { url_with_params foo: :bar }

    it 'does not add question mark' do
      expect(subject.call(url).count('?')).to eq 1
    end
  end

  describe 'when url have provider parameters' do
    let(:url) { url_with_params e: 12345 }

    it 'ignores and overwrites them' do
      expect(subject.call url, expires_in: 10).not_to include 'e=12345'
      expect(subject.call url, expires_in: 10).to match /e=\d+\&/
    end
  end

  it "adds h parameter" do
    expect(subject.call url).to match /&h=[a-z0-9]+\z/
  end

  it "does not include cookie params" do
    expect(subject.call url).not_to include 'cf='
    expect(subject.call url).not_to include 'cd='
  end

  describe 'cookie based auth' do
    let(:url) { url_with_params }

    it "adds cd parameter" do
      expect(subject.call url, cd: 100).to include 'cd=100'
    end

    it "adds cf parameter" do
      expect(subject.call url, cf: 100).not_to include 'cf=100'
      expect(subject.call url, cf: 100).to match /cf=\d+\&/
    end

    it "does not add e parameter" do
      expect(subject.call url, cd: 100, cf: 12345).not_to include 'e='
    end

    it "removes e parameter" do
      url << '?e=12345'
      expect(subject.call url, cd: 100, cf: 12345).not_to include 'e='
    end
  end

  private
  def url_with_params(**params)
    query_string = URI.encode_www_form params
    query_string = "?#{ query_string }" unless query_string.empty?
    "http://liveplay.example.com/limelight/testtokenstream/playlist.m3u8#{ query_string }"
  end
end
