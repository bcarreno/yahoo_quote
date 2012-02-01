$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'yahoo_quote'
require 'minitest/autorun'

class TestYahooQuote < MiniTest::Unit::TestCase
  #def test_something
    #y = YahooQuote
#
    #puts y.init("CSCO")
    #puts y.result
    #puts y.company_name_url
    #puts y.company_name
    #assert_match /Cisco/, y.company_name
  #end

  # test the 3 cases

  def test_get_company_name_succesfully
    YahooQuote.init('CSCO')
    text = File.read('test/fakeweb/csco.xml')
    FakeWeb.register_uri(:get, YahooQuote.company_name_url, :response => text)
    assert_equal "Cysco Food Supplies", YahooQuote.company_name
    FakeWeb.clean_registry
  end

  def test_get_company_name_from_cache
    # fetch success (implies a cache)
    # fake a bad answer from URL
    # fetch from cache
    YahooQuote.init('CSCO')
    text = File.read('test/fakeweb/csco.xml')
    FakeWeb.register_uri(:get, YahooQuote.company_name_url, :response => text)
    assert_equal "Cysco Food Supplies", YahooQuote.company_name

    # emulating a different run here

    YahooQuote.init('CSCO')
    text = File.read('test/fakeweb/csco_bad.xml')
    refute_match /Cysco/i, text
    FakeWeb.register_uri(:get, YahooQuote.company_name_url, :response => text)
    assert_equal "Cysco Food Supplies", YahooQuote.company_name
    FakeWeb.clean_registry
  end
end
