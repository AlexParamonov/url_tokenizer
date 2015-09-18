require 'spec_helper'
require 'url_tokenizer/cdn77'

describe UrlTokenizer::CDN77 do
  subject { described_class.new key }
  let(:key) { "secret" }
  let(:url) { url_with_params }

  describe 'when url have the query string' do
    let(:url) { url_with_params foo: :bar }

    it 'removes the query string' do
      expect(subject.call url).not_to include 'foo'
      expect(subject.call url).not_to include 'bar'
    end
  end

  describe 'when requesting token for domain' do
    it 'returns nil' do
      url = 'http://liveplay.example.com/'
      expect(subject.call url).to be_nil

      url = 'http://liveplay.example.com'
      expect(subject.call url).to be_nil
    end
  end

  it "adds secure parameter" do
    expect(subject.call url).to include 'secure='
  end

  describe 'with expiration time' do
    it "adds timestamp" do
      expect(subject.call url, expires_in: 123).to match /,\d+$/
    end

  end

  describe 'with real data' do
    let(:key) { "secret" }

    pending "is successful" do
      url = subject.call "http://vod15play.malimarcdn.com/vod15/mp4:sample.mp4/playlist.m3u8", expires_in: 11111111

      uri = URI.parse url
      is_request_successful = Net::HTTP.start(uri.host, uri.port) do |http|
        http.head(uri.request_uri).code == "200"
      end
      expect(is_request_successful).to be_truthy
    end
  end


  private
  def url_with_params(**params)
    query_string = URI.encode_www_form params
    query_string = "?#{ query_string }" unless query_string.empty?
    "http://liveplay.example.com/cdn77/testtokenstream/playlist.m3u8#{ query_string }"
  end
end
