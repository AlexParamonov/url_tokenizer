$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dotenv'
Dotenv.load

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'url_tokenizer'
