$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'dotenv'
Dotenv.load

require 'simplecov'
SimpleCov.start

require 'url_tokenizer'
