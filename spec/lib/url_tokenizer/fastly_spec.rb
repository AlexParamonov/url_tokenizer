require 'spec_helper'
require 'url_tokenizer/fastly'
require 'support/real_data_context'
require_relative 'provider_examples'

describe UrlTokenizer::Fastly do
  it_behaves_like :provider

  subject { described_class.new key }
  let(:key) { "secret" }
  let(:url) { url_with_params }

  describe 'when url have the query string' do
    let(:url) { url_with_params foo: :bar }

    it 'does not add question mark' do
      expect(subject.call(url).count('?')).to eq 1
    end

    it 'persists query string' do
      expect(subject.call url).to include "foo=bar"
    end
  end

  it "adds token to path" do
    path = URI(subject.call url).path

    expect(path).to match /\A\/\w+\/fastly/
  end

  describe 'with expiration time' do
    it "adds timestamp" do
      expect(subject.call url, expires_in: 123).to match /example.com\/\d+_/
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
      actual_expiration_time = subject.call(url).match(/example.com\/(\d+)_/)[1].to_i
      expect(actual_expiration_time).to be_within(2).of(global_expiration_time)
    end

    it "prefers local options" do
      local_expiration_time = (Time.now.utc + 10).to_i

      actual_expiration_time = subject.call(url, expires_in: 10).match(/example.com\/(\d+)_/)[1].to_i
      expect(actual_expiration_time).to be_within(2).of(local_expiration_time)
    end
  end

  private
  def url_with_params(**params)
    query_string = URI.encode_www_form params
    query_string = "?#{ query_string }" unless query_string.empty?
    "http://liveplay.example.com/fastly/testtokenstream/playlist.m3u8#{ query_string }"
  end
end
