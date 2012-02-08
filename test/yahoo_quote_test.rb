$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'yahoo_quote'
require 'minitest/autorun'
require 'fakeweb'

# test error:    YahooQuote::Configuration.cache_dir = "/etc/kk"
#
class TestYahooQuote < MiniTest::Unit::TestCase
  def setup
    # TODO make gem method to clear the cache
    `rm -f /tmp/*csv`
  end

  def test_live_quote
    quote = YahooQuote::Quote.new('CSCO', ['Symbol', 'Name'])
    assert_equal "CSCO",              quote.data["Symbol"]
    assert_equal "Cisco Systems, In", quote.data["Name"]
  end

  def test_invalid_ticker_symbol
    quote = YahooQuote::Quote.new('ECOMMERCE', ['Symbol', 'Name', 'Market Capitalization'])
    assert_nil quote.data["Name"]
    assert_equal false, quote.valid?
    # TODO check no cached
  end

  def test_get_quote
    quote = YahooQuote::Quote.new('AAPL', ['Symbol', 'Name', 'Last Trade (Price Only)', 'Market Capitalization'])
    FakeWeb.register_uri(:get, quote.quote_url, :response => File.read('test/fakeweb/aapl.csv'))
    assert_equal "Apple Inc.", quote.data["Name"]
    assert_equal 463.97,       quote.data["Last Trade (Price Only)"].to_f
    assert_equal '432.6B',     quote.data["Market Capitalization"]
  end

  def test_graph_url
    quote = YahooQuote::Quote.new('AAPL', ['Symbol', 'Name', 'Last Trade (Price Only)', 'Market Capitalization'])
    FakeWeb.register_uri(:get, quote.quote_url, :response => File.read('test/fakeweb/aapl.csv'))
    # TODO this should not be necessary
    assert_equal "Apple Inc.", quote.data["Name"]
    assert_match %r(^http://chart.finance.yahoo.com/z\?s=AAPL), quote.graph_url
  end

  def test_get_quote_from_cache
    YahooQuote::Configuration.cache_dir = "/tmp"
    quote = YahooQuote::Quote.new('AAPL', ['Symbol', 'Name', 'Last Trade (Price Only)'])
    FakeWeb.register_uri(:get, quote.quote_url, :response => File.read('test/fakeweb/aapl.csv'))
    assert_equal "Apple Inc.", quote.data["Name"]
    assert_equal 463.97,       quote.data["Last Trade (Price Only)"].to_f
    # the quote should be cached now
    quote2 = YahooQuote::Quote.new('AAPL', ['Symbol', 'Name', 'Last Trade (Price Only)'])
    response = File.read('test/fakeweb/aapl_bad.csv')
    refute_match /Apple/i, response
    FakeWeb.register_uri(:get, quote2.quote_url, :response => response)
    assert_equal "Apple Inc.", quote2.data["Name"]
    assert_equal 463.97,       quote2.data["Last Trade (Price Only)"].to_f
  end
end
