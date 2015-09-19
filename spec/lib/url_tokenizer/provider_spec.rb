require 'spec_helper'
require_relative 'provider_examples'

describe UrlTokenizer::Provider do
  it_behaves_like :provider

  subject { described_class.new key }
  let(:key) { "secret key" }
end
