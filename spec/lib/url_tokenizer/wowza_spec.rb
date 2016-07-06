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

  describe 'ip restriction' do
    it "adds ip parameter" do
      expect(subject.call url, ip: '127.0.0.1').to include 'ip=127.0.0.1'
    end

    describe 'when ip restriction disabled' do
      subject { described_class.new key, ip: false }

      it "adds ip parameter" do
        expect(subject.call url, ip: '127.0.0.1').not_to include 'ip=127.0.0.1'
      end
    end
  end

  describe 'with real data' do
    include_context "real_data_context" do
      let(:key) { ENV['WOWZA_TOKEN'] }
      let(:url) { "http://sanorigin00.malimarcdn.com:1935/hdliveedge00/ch8hd.stream/playlist.m3u8" }
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

  describe 'global options' do
    subject { described_class.new key, expires_in: 12345 }

    it "uses global options" do
      global_expiration_time = (Time.now.utc + 12345).to_i
      actual_expiration_time = subject.call(url).match(/wowzatokenendtime=(\d+)/)[1].to_i
      expect(actual_expiration_time).to be_within(2).of(global_expiration_time)
    end

    it "prefers local options" do
      local_expiration_time = (Time.now.utc + 10).to_i

      actual_expiration_time = subject.call(url, expires_in: 10).match(/wowzatokenendtime=(\d+)/)[1].to_i
      expect(actual_expiration_time).to be_within(2).of(local_expiration_time)
    end
  end

  describe 'ignore_in_path option' do
    let(:url) { 'http://liveplay.example.com/ignore_me/please/wowza/playlist.m3u8' }
    let(:ignore_in_path_option) { "ignore_me/please/" }

    it 'skips matching text from been part of string to tokenize' do
      expect(subject).not_to receive(:digest).with /#{ ignore_in_path_option }/

      subject.call(url, ignore_in_path: ignore_in_path_option)
    end
  end

  private
  def url_with_params(**params)
    query_string = URI.encode_www_form params
    query_string = "?#{ query_string }" unless query_string.empty?
    "http://liveplay.example.com/wowza/testtokenstream/playlist.m3u8#{ query_string }"
  end
end
