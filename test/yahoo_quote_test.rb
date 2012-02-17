$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'yahoo_quote'
require 'minitest/autorun'
require 'fakeweb'

# TODO test 2 things: make intermediate dirs for cache and permissions

class TestYahooQuote < MiniTest::Unit::TestCase
  def setup
    @url_regexp = %r(http://download\.finance\.yahoo\.com/d/quotes\.csv\?)
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, @url_regexp, :response => File.read("test/fakeweb/aapl_good.csv"))

    # TODO make gem method to clear the cache
    `rm -f /tmp/*csv`
  end

  def test_empty_arguments
    quote = YahooQuote::Quote.new('', [])
    assert_equal false, quote.valid?
    assert_nil quote.data["Symbol"]
    assert_nil quote.data["Name"]
  end

  def test_bad_symbol
    quote = YahooQuote::Quote.new('C A', ['Symbol', 'Name'])
    assert_equal false, quote.valid?
    assert_nil quote.data["Symbol"]
    assert_nil quote.data["Name"]
  end

  def test_non_existing_company
    FakeWeb.register_uri(:get, @url_regexp, :response => File.read("test/fakeweb/ecommerce.csv"))
    quote = YahooQuote::Quote.new('ECOMMERCE', ['Symbol', 'Name'])
    assert_equal false, quote.valid?
    assert_nil quote.data["Symbol"]
    assert_nil quote.data["Name"]
  end

  def test_good_quote
    quote = YahooQuote::Quote.new('AAPL', ['Name', 'Last Trade (Price Only)', 'P/E Ratio'])
    assert_equal "Apple Inc.", quote.data["Name"]
    assert_equal 503.65,       quote.data["Last Trade (Price Only)"]
    assert_equal 14.16,        quote.data["P/E Ratio"]
  end

  def test_graph_url
    quote = YahooQuote::Quote.new('AAPL', [])
    assert quote.valid?
    assert_match %r(^http://chart.finance.yahoo.com/z\?s=AAPL), quote.graph_url
  end

  def test_get_quote_from_cache
    YahooQuote::Configuration.cache_dir = "test/cache"
    quote = YahooQuote::Quote.new('AAPL', ['Name', 'Last Trade (Price Only)', 'P/E Ratio'])
    assert File.file? "test/cache/AAPL.csv"
    assert_equal "Apple Inc.", quote.data["Name"]
    assert_equal 503.65,       quote.data["Last Trade (Price Only)"]
    bad_response = File.read('test/fakeweb/aapl_bad.csv')
    refute_match /Apple/i, bad_response
    FakeWeb.register_uri(:get, @url_regexp, :response => bad_response)
    cached_quote = YahooQuote::Quote.new('AAPL', ['Name', 'Last Trade (Price Only)', 'P/E Ratio'])
    assert_equal "Apple Inc.", cached_quote.data["Name"]
    assert_equal 503.65,       cached_quote.data["Last Trade (Price Only)"]
    YahooQuote::Configuration.cache_dir = nil
  end
end
