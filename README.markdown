# yahoo_quote

Easy interaction with Yahoo Finance API

## Installation

    gem install yahoo_quote

## Usage

```ruby
require 'yahoo_quote'
quote = YahooQuote::Quote.new('AAPL', ['Name', 'Last Trade (Price Only)', 'P/E Ratio'])
quote.valid?
# => true
quote.data['Name']
# => "Apple Inc."
quote.data['Last Trade (Price Only)']
# => 502.12
quote.data['P/E Ratio']
# => 14.29
quote = YahooQuote::Quote.new('ECOMMERCE', ['Name', 'Last Trade (Price Only)', 'P/E Ratio'])
quote.valid?
# => false
```

To get list of supported fields:

```ruby
puts quote.field_mappings.keys
````

## Configuration

Use /tmp to keep a simple cache:

```ruby
YahooQuote::Configuration.cache_dir = "/tmp"
```

## Copyright

Copyright (c) 2012 Braulio Carreno. See LICENSE for details.
