$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'yahoo_quote'
require 'minitest/autorun'

class TestYahooQuote < MiniTest::Unit::TestCase
  def setup
    # make gem method to clear the cache
    `rm -f /tmp/*csv`
  end

  # test the 3 issues cases
#  def test_get_company_name_succesfully
#    quote = YahooQuote::Quote.new('AAPL')
#    puts quote.company_name_url
#    text = File.read('test/fakeweb/aapl.xml')
#    FakeWeb.register_uri(:get, quote.company_name_url, :response => text)
#    assert_equal "Apple Inc.", quote.company_name
#    FakeWeb.clean_registry
#  end

  def test_live_quote
    quote = YahooQuote::Quote.new('CSCO', ['Symbol', 'Name'])
    assert_equal "CSCO",              quote.data["Symbol"]
    assert_equal "Cisco Systems, In", quote.data["Name"]
  end
  
  def test_get_quote
    quote = YahooQuote::Quote.new('AAPL', ['Symbol', 'Name', 'Last Trade (Price Only)'])
    puts quote.quote_url
    text = File.read('test/fakeweb/aapl.csv')
    FakeWeb.register_uri(:get, quote.quote_url, :response => text)
    assert_equal "Apple Inc.", quote.data["Name"]
    FakeWeb.clean_registry
  end

  def test_get_quote_from_cache
    quote = YahooQuote::Quote.new('AAPL', ['Symbol', 'Name', 'Last Trade (Price Only)'])
    text = File.read('test/fakeweb/aapl.csv')
    FakeWeb.register_uri(:get, quote.quote_url, :response => text)
    assert_equal "Apple Inc.", quote.data["Name"]
    assert_equal 463.43,       quote.data["Last Trade (Price Only)"].to_f
    # the quote should be cached now
    debugger
    quote2 = YahooQuote::Quote.new('AAPL', ['Symbol', 'Name', 'Last Trade (Price Only)'])
    text = File.read('test/fakeweb/aapl_bad.csv')
    refute_match /Apple/i, text
    FakeWeb.register_uri(:get, quote2.quote_url, :response => text)
    assert_equal "Apple Inc.", quote2.data["Name"]
    assert_equal 463.43,       quote2.data["Last Trade (Price Only)"].to_f
    FakeWeb.clean_registry
  end
end
