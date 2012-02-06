require "yahoo_quote/version"
require "yahoo_quote/configuration"

require 'open-uri'

require 'nokogiri'
require 'fakeweb'

require 'ruby-debug'

    # Possible issues:
    # 1. Bad domain name ==> exception: 
    # /Users/bcarreno/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/net/http.rb:644:in
    # `initialize': getaddrinfo: nodename nor servname provided, or not known (SocketError)
    # 2. http://zen-secure.com/ ==> timeout
    # /Users/bcarreno/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/net/http.rb:644:in `initialize': Operation timed out - connect(2) (Errno::ETIMEDOUT)
    # 3. text returned doesn't contain what you expect, error for example.

module YahooQuote
  class Quote
    def initialize(symbol, fields)
      @symbol = symbol.gsub(".", '') # yahoo csv expects no periods
      @fields = fields
    end

    def field_mappings
      {
        'Symbol'                          => 's',
        'Name'                            => 'n',
        'Last Trade (Price Only)'         => 'l1',
        'Market Capitalization'           => 'j1',
        '52-week Range'                   => 'w',
        'Volume'                          => 'v',
        'P/E Ratio'                       => 'r',
        'EPS Estimate Current Year'       => 'e7',
        'EPS Estimate Next Year'          => 'e8',
        'Price/EPS Estimate Current Year' => 'r6',
        'Price/EPS Estimate Next Year'    => 'r7',
      }
    end

    def parse_csv(csv)
      # yahoo csv is not CSV compliant (commas not escaped when part of field)
      values = csv.chomp.split(/\",/).map{|x| x.gsub(/(^"|"$)/, '')}
      # check result.size == fields.size
      data = {}
      values.each_with_index {|value, i| data[@fields[i]] = value}
      data
    end

    def company_name_url
      "http://query.yahooapis.com/v1/public/yql?q=select%20CompanyName%20from%20yahoo.finance.stocks%20where%20symbol%3D%22#{@symbol}%22&format=xml&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
    end

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
        csv = file?(file_name) ? File.read(file_name) : ""
      end
      @data = parse_csv(csv)
      if valid?
        File.open(filename_quote, 'w') {|f| f.write(csv) }
      else
        csv = file?(file_name) ? File.read(file_name) : ""
        @data = parse_csv(csv)
      end
      @data
    end

    def parse_url(url)
      URI.parse(url)
    end
  
    def read_url(io)
      begin
        text = io.read
      rescue
        return file?(file_name) ? File.read(file_name) : ""
      end
    end
  
    def filename_quote
      YahooQuote::Configuration.cache_dir + "/#{@symbol}.csv"
    end

    def valid?
      @data.size > 0
    end
  end
end
