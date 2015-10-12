require 'spec_helper'
require 'url_tokenizer/wowza'
require 'support/real_data_context'
require_relative 'provider_examples'

describe UrlTokenizer::Wowza do
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

  it "adds token parameter" do
    expect(subject.call url).to include 'wowzatokenhash='
  end

  describe 'with real data' do
    include_context "real_data_context" do
      let(:key) { ENV['WOWZA_TOKEN'] }
      let(:url) { "http://sanorigin00.malimarcdn.com:1935/onair15edge/_definst_/mp4:onair15/onair/sample.mp4/playlist.m3u8" }
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
    "http://liveplay.example.com/wowza/testtokenstream/playlist.m3u8#{ query_string }"
  end
end
