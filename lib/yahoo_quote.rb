require "yahoo_quote/version"

require 'open-uri'
require 'csv'

require 'nokogiri'
require 'fakeweb'

require 'ruby-debug'

module YahooQuote
  extend self

  def init(symbol)
    @symbol = symbol.gsub(".", '') # yahoo csv expects no periods
    parse_csv
  end

  def parse_csv
    # abort if symbol has a weird character
    if @symbol =~ /\W/
      return
    end
    keys = "snl1j1s1wvre7e8r6r7"
    @command = %Q|curl -sL "http://finance.yahoo.com/d/quotes.csv?s=#@symbol&f=#{keys}" |
    @csv ||= %x[ #{@command} ]
    @data = CSV.parse_line @csv
    @symbol, @name = *@data
  end

  def valid?
    return false unless @data
    @data[3] != "N/A"
  end

  def company_name_url
    "http://query.yahooapis.com/v1/public/yql?q=select%20CompanyName%20from%20yahoo.finance.stocks%20where%20symbol%3D%22#{@symbol}%22&format=xml&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
#    "http://zen-secure.com/"
  end

  def company_name
    return unless valid?
#    return @company_name if @company_name
    res = URI.parse(company_name_url).read
    # Possible issues:
    # 1. Bad domain name ==> exception: 
    # /Users/bcarreno/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/net/http.rb:644:in
    # `initialize': getaddrinfo: nodename nor servname provided, or not known (SocketError)
    # 2. http://zen-secure.com/ ==> timeout
    # /Users/bcarreno/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/net/http.rb:644:in `initialize': Operation timed out - connect(2) (Errno::ETIMEDOUT)
    # 3. text returned doesn't contain what you expect, error for example.
    @company_name = Nokogiri::XML.parse(res).at("//CompanyName").inner_text
  #rescue
#    "No company name found"
  end

  def result
    "This is the Yahoo Quote gem #{@symbol} #{@csv}"
  end
end
