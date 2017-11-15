require 'spec_helper'
require 'url_tokenizer/fastly_query_string'
require 'support/real_data_context'
require_relative 'provider_examples'

describe UrlTokenizer::FastlyQueryString do
  it_behaves_like :provider

  subject { described_class.new key }
  let(:key) { "secret" }
  let(:url) { url_with_params }

  it "adds token parameter" do
    expect(subject.call url).to include 'token='
  end

  describe 'when url have the query string' do
    let(:url) { url_with_params foo: :bar }

    it 'does not add question mark' do
      expect(subject.call(url).count('?')).to eq 1
    end

    it 'persists query string' do
      expect(subject.call url).to include "foo=bar"
    end
  end

  describe 'when url have provider parameters' do
    let(:url) { url_with_params token: '0000000000_e5e9fa1ba31ecd1ae84f75caaa474f3a663f05f4' }

    it 'ignores and overwrites them' do
      expect(subject.call url, expires_in: 10).not_to include '0000000000_'
      expect(subject.call url, expires_in: 10).to match /token=\d{10,}_/
    end
  end

  describe 'with expiration time' do
    it "adds timestamp" do
      expect(subject.call url, expires_in: 123).to match /\=\d+_/
    end
  end

  describe 'with real data', real_data: true do
    include_context "real_data_context" do
      let(:expires_in) { 86400 }
      let(:key) { ENV['FASTLY_TOKEN'] }
      let(:url) { "url_goes_here" }
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
      actual_expiration_time = subject.call(url).match(/\=(\d+)/)[1].to_i
      expect(actual_expiration_time).to be_within(2).of(global_expiration_time)
    end

    it "prefers local options" do
      local_expiration_time = (Time.now.utc + 10).to_i

      actual_expiration_time = subject.call(url, expires_in: 10).match(/\=(\d+)/)[1].to_i
      expect(actual_expiration_time).to be_within(2).of(local_expiration_time)
    end
  end

  describe 'ads' do
    describe 'with real data', real_data: true do
      include_context "real_data_context" do
        let(:expires_in) { 86400 }
        let(:key) { ENV['FASTLY_TOKEN'] }
        let(:url) { "url_goes_here" }
      end
    end
  end

  private
  def url_with_params(**params)
    query_string = URI.encode_www_form params
    query_string = "?#{ query_string }" unless query_string.empty?
    "http://liveplay.example.com/fastly/testtokenstream/playlist.m3u8#{ query_string }"
  end
end
