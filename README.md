UrlTokenizer
================================
[![Build Status](https://travis-ci.org/AlexParamonov/url_tokenizer.png?branch=master)](https://travis-ci.org/AlexParamonov/url_tokenizer)
[![Gemnasium Build Status](https://gemnasium.com/AlexParamonov/url_tokenizer.png)](http://gemnasium.com/AlexParamonov/url_tokenizer)
[![Gem Version](https://badge.fury.io/rb/url_tokenizer.png)](http://badge.fury.io/rb/url_tokenizer)
[![Test Coverage](https://codeclimate.com/github/AlexParamonov/url_tokenizer/badges/coverage.svg)](https://codeclimate.com/github/AlexParamonov/url_tokenizer/coverage)
[![Code Climate](https://codeclimate.com/github/AlexParamonov/url_tokenizer.png)](https://codeclimate.com/github/AlexParamonov/url_tokenizer)

Tokenize url by variety of providers

Contents
---------
1. Installation
1. Requirements
1. Contacts
1. Compatibility
1. Contributing
1. Copyright

Installation
------------

Add this line to your application's Gemfile:

    gem 'url_tokenizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install url_tokenizer

UrlTokenizer gem has Limelight and CDN77 providers bundled.

Requirements
------------
1. Ruby >= 2.1

Usage
------------

Register provider using `UrlTokenizer.register`

``` ruby
require 'url_tokenizer/limelight'
UrlTokenizer.register 'LL' => UrlTokenizer::Limelight.new('super_secret_key')
```

Obtain provider and tokenize url:

``` ruby
tokenizer = UrlTokenizer.provider 'LL'
tokenizer.call url, expires_in: 1.hour
```

Contacts
-------------
Have questions or recommendations? Contact me via `alexander.n.paramonov@gmail.com`

Found a bug or have enhancement request? You are welcome at [Github bugtracker](https://github.com/AlexParamonov/url_tokenizer/issues)


Compatibility
-------------
tested with Ruby:

* 2.2
* 2.1
* ruby-head
* rbx-2
* jruby-head

See [build history](http://travis-ci.org/#!/AlexParamonov/url_tokenizer/builds)


## Contributing

1. Fork repository ( http://github.com/AlexParamonov/url_tokenizer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Copyright
---------
Copyright © 2015 Alexander Paramonov.  
Released under the MIT License. See the LICENSE file for further details.
