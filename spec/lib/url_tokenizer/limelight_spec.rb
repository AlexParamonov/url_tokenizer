require 'spec_helper'
require 'url_tokenizer/limelight'
require 'support/real_data_context'
require_relative 'provider_examples'

describe UrlTokenizer::Limelight do
  it_behaves_like :provider

  subject { described_class.new key }
  let(:key) { "secret" }
  let(:url) { url_with_params }

  describe 'when url have the query string with parameters' do
    let(:url) { url_with_params foo: :bar }

    it 'does not add question mark' do
      expect(subject.call(url).count('?')).to eq 1
    end

    it 'persists query string' do
      expect(subject.call url).to include "foo=bar"
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

    describe 'global options' do
      subject { described_class.new key, cf: 12345 }

      it "uses global options" do
        global_expiration_time = (Time.now.utc + 12345).to_i
        actual_expiration_time = subject.call(url).match(/cf=(\d+)/)[1].to_i
        expect(actual_expiration_time).to be_within(2).of(global_expiration_time)
      end

      it "prefers local options" do
        local_expiration_time = (Time.now.utc + 10).to_i

        actual_expiration_time = subject.call(url, cf: 10).match(/cf=(\d+)/)[1].to_i
        expect(actual_expiration_time).to be_within(2).of(local_expiration_time)
      end
    end
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

  describe 'with real data', real_data: true do
    include_context "real_data_context" do
      let(:key) { ENV['LL_TOKEN'] }
      let(:url) { "url_goes_here" }
    end
  end

  describe 'global options' do
    subject { described_class.new key, expires_in: 12345 }

    it "uses global options" do
      global_expiration_time = (Time.now.utc + 12345).to_i
      actual_expiration_time = subject.call(url).match(/e=(\d+)/)[1].to_i
      expect(actual_expiration_time).to be_within(2).of(global_expiration_time)
    end

    it "prefers local options" do
      local_expiration_time = (Time.now.utc + 10).to_i

      actual_expiration_time = subject.call(url, expires_in: 10).match(/e=(\d+)/)[1].to_i
      expect(actual_expiration_time).to be_within(2).of(local_expiration_time)
    end
  end

  private
  def url_with_params(**params)
    query_string = URI.encode_www_form params
    query_string = "?#{ query_string }" unless query_string.empty?
    "http://liveplay.example.com/limelight/testtokenstream/playlist.m3u8#{ query_string }"
  end
end
