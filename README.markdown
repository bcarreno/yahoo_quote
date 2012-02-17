# yahoo_quote

Easy interaction with Yahoo Finance API

## Installation

    gem install yahoo_quote

## Usage

    quote = YahooQuote::Quote.new('CSCO', ['Symbol', 'Name'])
    assert_equal "CSCO",              quote.data["Symbol"]
    assert_equal "Cisco Systems, In", quote.data["Name"]


To get list of supported fields:

   yq.field_mappings.keys

## Copyright

Copyright (c) 2012 Braulio Carreno. See LICENSE for details.
