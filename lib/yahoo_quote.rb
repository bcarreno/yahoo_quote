require "yahoo_quote/version"
require "yahoo_quote/configuration"

require 'open-uri'
require 'csv'

module YahooQuote
  class Quote
    def initialize(symbol, fields)
      @symbol = symbol.gsub(".", '') # yahoo csv expects no periods
      @fields = fields
    end

    def field_mappings
      {
        "1 yr Target Price" => "t8",
        "200-day Moving Average" => "m4",
        "50-day Moving Average" => "m3",
        "52-week High" => "k",
        "52-week Low" => "j",
        "52-week Range" => "w",
        "After Hours Change (Real-time)" => "c8",
        "Annualized Gain" => "g3",
        "Ask (Real-time)" => "b2",
        "Ask Size" => "a5",
        "Ask" => "a",
        "Average Daily Volume" => "a2",
        "Bid (Real-time)" => "b3",
        "Bid Size" => "b6",
        "Bid" => "b",
        "Book Value" => "b4",
        "Change & Percent Change" => "c",
        "Change (Real-time)" => "c6",
        "Change From 200-day Moving Average" => "m5",
        "Change From 50-day Moving Average" => "m7",
        "Change From 52-week High" => "k4",
        "Change From 52-week Low" => "j5",
        "Change Percent (Real-time)" => "k2",
        "Change in Percent" => "p2",
        "Change" => "c1",
        "Commission" => "c3",
        "Day's High" => "h",
        "Day's Low" => "g",
        "Day's Range (Real-time)" => "m2",
        "Day's Range" => "m",
        "Day's Value Change (Real-time)" => "w4",
        "Day's Value Change" => "w1",
        "Dividend Pay Date" => "r1",
        "Dividend Yield" => "y",
        "Dividend/Share" => "d",
        "EBITDA" => "j4",
        "EPS Estimate Current Year" => "e7",
        "EPS Estimate Next Quarter" => "e9",
        "EPS Estimate Next Year" => "e8",
        "Earnings/Share" => "e",
        "Error Indication (returned for symbol changed / invalid)" => "e1",
        "Ex-Dividend Date" => "q",
        "Float Shares" => "f6",
        "High Limit" => "l2",
        "Holdings Gain (Real-time)" => "g6",
        "Holdings Gain Percent (Real-time)" => "g5",
        "Holdings Gain Percent" => "g1",
        "Holdings Gain" => "g4",
        "Holdings Value (Real-time)" => "v7",
        "Holdings Value" => "v1",
        "Last Trade (Price Only)" => "l1",
        "Last Trade (Real-time) With Time" => "k1",
        "Last Trade (With Time)" => "l",
        "Last Trade Date" => "d1",
        "Last Trade Size" => "k3",
        "Last Trade Time" => "t1",
        "Low Limit" => "l3",
        "Market Cap (Real-time)" => "j3",
        "Market Capitalization" => "j1",
        "More Info" => "i",
        "Name" => "n",
        "Notes" => "n4",
        "Open" => "o",
        "Order Book (Real-time)" => "i5",
        "P/E Ratio (Real-time)" => "r2",
        "P/E Ratio" => "r",
        "PEG Ratio" => "r5",
        "Percebt Change From 52-week High" => "k5",
        "Percent Change From 200-day Moving Average" => "m6",
        "Percent Change From 50-day Moving Average" => "m8",
        "Percent Change From 52-week Low" => "j6",
        "Previous Close" => "p",
        "Price Paid" => "p1",
        "Price/Book" => "p6",
        "Price/EPS Estimate Current Year" => "r6",
        "Price/EPS Estimate Next Year" => "r7",
        "Price/Sales" => "p5",
        "Shares Owned" => "s1",
        "Short Ratio" => "s7",
        "Stock Exchange" => "x",
        "Symbol" => "s",
        "Ticker Trend" => "t7",
        "Trade Date" => "d2",
        "Trade Links" => "t6",
        "Volume" => "v",
      }
    end

    def parse_csv(csv)
      values = CSV.parse_line(csv)
      # TODO check result.size == fields.size
      data = {}
      values.each_with_index {|value, i| data[@fields[i]] = value}
      data
    end

#    def company_name_url
#      "http://query.yahooapis.com/v1/public/yql?q=select%20CompanyName%20from%20yahoo.finance.stocks%20where%20symbol%3D%22#{@symbol}%22&format=xml&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
#    end

    def quote_url
      tags = @fields.map{|x| field_mappings[x]}.join
      "http://download.finance.yahoo.com/d/quotes.csv?s=#{@symbol}&f=#{tags}"
    end      
  
    def data
      return @data if @data && valid?

      io = URI.parse(quote_url)
      begin
        csv = io.read
      rescue
        csv = ''
      end
      @data = parse_csv(csv)
      if cache_response? && valid?
        File.open(filename_quote, 'wb') {|f| Marshal.dump(@data, f) }
      elsif cache_response? && File.file?(filename_quote)
        @data = File.open(filename_quote, 'rb') {|f| Marshal.load(f) }
      end
      @data
    end

    def filename_quote
      YahooQuote::Configuration.cache_dir + "/#{@symbol}.dump"
    end

    def valid?
      @data.size > 1
    end

    def cache_response?
      YahooQuote::Configuration.cache_dir
    end
  end
end
