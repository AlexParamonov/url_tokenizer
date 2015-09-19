require 'spec_helper'
require 'url_tokenizer/cdn77'
require 'support/real_data_context'
require_relative 'provider_examples'

describe UrlTokenizer::CDN77 do
  it_behaves_like :provider

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

  it "adds secure parameter" do
    expect(subject.call url).to include 'secure='
  end

  describe 'with expiration time' do
    it "adds timestamp" do
      expect(subject.call url, expires_in: 123).to match /,\d+$/
    end
  end

  describe 'with real data' do
    include_context "real_data_context" do
      let(:key) { ENV['CDN77_TOKEN'] }
      let(:url) { "http://vod15play.malimarcdn.com/vod15/mp4:sample.mp4/playlist.m3u8" }
    end
  end

  describe 'when requesting token for domain, not for url' do
    it 'returns nil' do
      url = 'http://liveplay.example.com/'
      expect(subject.call url).to be_nil

      url = 'http://liveplay.example.com'
      expect(subject.call url).to be_nil
    end
  end

  private
  def url_with_params(**params)
    query_string = URI.encode_www_form params
    query_string = "?#{ query_string }" unless query_string.empty?
    "http://liveplay.example.com/cdn77/testtokenstream/playlist.m3u8#{ query_string }"
  end
end
