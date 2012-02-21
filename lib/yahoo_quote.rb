require "yahoo_quote/version"
require "yahoo_quote/configuration"

require 'open-uri'
require 'csv'

class Hash
  def self.csv_load( meta, headers, fields )
    self[*headers.zip(fields).flatten.map { |e| eval(e) }]
  end

  def csv_headers
    keys.map { |key| key.inspect }
  end

  def csv_dump( headers )
    headers.map { |header| fetch(eval(header)).inspect }
  end
end

module YahooQuote
  class Quote
    def initialize(symbol, fields)
      @symbol = symbol.gsub(".", '') # yahoo csv expects no periods
      @fields = fields
      # used by validate method
      @fields << "Market Capitalization" unless @fields.include? "Market Capitalization"
      pull_data
    end

    def valid?
      return false unless @data
      @data.size > 0
    end

    def data
      @data.nil? ? {} : @data
    end

    def cache_response?
      YahooQuote::Configuration.cache_dir
    end

    def filename_quote
      File.join(YahooQuote::Configuration.cache_dir, "#{@symbol}.csv")
    end

    def clear_cache
      Dir.glob(File.join(YahooQuote::Configuration.cache_dir, '*.csv')).each {|f|
        File.unlink f }
    end

    def quote_url
      tags = @fields.map{|x| field_mappings[x]}.join
      "http://download.finance.yahoo.com/d/quotes.csv?s=#{@symbol}&f=#{tags}"
    end

    def graph_url
      return nil unless valid?
      "http://chart.finance.yahoo.com/z?s=#{@symbol}&t=1y&q=&l=&z=l&p=s&a=v&p=s&lang=en-US&region=US"
    end

#    Not working any longer
#    def company_name_url
#      "http://query.yahooapis.com/v1/public/yql?q=select%20CompanyName%20from%20yahoo.finance.stocks%20where%20symbol%3D%22#{@symbol}%22&format=xml&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
#    end

    def field_mappings
      # From http://cliffngan.net/a/13
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

    private

    def pull_data
      # abort if symbol has a weird character
      return if @symbol.empty? || @symbol =~ /\W/

      io = URI.parse(quote_url)
      begin
        csv = io.read
      rescue
        csv = ''
      end
      @data = validate(parse_csv(csv))
      if cache_response?
        if valid?
          File.open(filename_quote, 'w') {|f| CSV.dump([@data], f) }
        elsif File.file?(filename_quote)
          @data = (File.open(filename_quote, 'r') {|f| CSV.load(f)}).first
        end
      end
    end

    def parse_csv(csv)
      values = CSV.parse_line(csv, :converters => :numeric)
      # TODO check result.size == fields.size
      response = {}
      values.each_with_index {|value, i| response[@fields[i]] = value}
      response
    end

    def validate(response)
      # Yahoo csv returns values even if ticker symbol is invalid,
      # use this condition to make sure the response is ok.
      response["Market Capitalization"] == 'N/A' ? {} : response
    end
  end
end
