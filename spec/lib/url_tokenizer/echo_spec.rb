require 'spec_helper'
require 'url_tokenizer/echo'

describe UrlTokenizer::Echo do
  subject(:tokenizer) { described_class.new }

  it "returns input url unchanged" do
    input_url = 'http://something.com'
    output_url = subject.call(input_url)

    expect(output_url).to eq input_url
  end
end
