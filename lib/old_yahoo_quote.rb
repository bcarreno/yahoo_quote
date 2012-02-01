require 'csv'
require 'open-uri'
require 'nokogiri'

# Gets company name, quote and stock graph
# See http://cliffngan.net/a/13
#
class YahooQuote
  attr_accessor :name, :data, :csv, :command

  def initialize(symbol)
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

  def company_name_orig
    valid? ? name : nil
  end

  def company_name
    return unless valid?
    return @company_name if @company_name
    res = `curl -Ls "http://query.yahooapis.com/v1/public/yql?q=select%20CompanyName%20from%20yahoo.finance.stocks%20where%20symbol%3D%22#{@symbol}%22&format=xml&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"`
    @company_name = Nokogiri::XML.parse(res).at("//CompanyName").inner_text
  rescue
    "No company name found"
  end

  def day_graph_url
    return nil unless valid?
    "http://ichart.finance.yahoo.com/t?s=#@symbol"
  end

  # the year graph
  def graph_url 
    return nil unless valid?
    "http://chart.finance.yahoo.com/z?s=#{@symbol}&t=1y&q=&l=&z=l&p=s&a=v&p=s&lang=en-US&region=US"
  end

  def graph_header
    return nil unless valid?
    url = "http://ichart.finance.yahoo.com/t?s=#@symbol"
    url + "\n" +  `curl -sI "#{url}"`
  end
end

if __FILE__ == $0
  puts ARGV.first
  y = YahooQuote.new ARGV.first
  puts y.name
  puts y.company_name
  puts y.csv.inspect
  puts y.data.inspect

end


__END__


Usage

y = YahooQuote.new("AMZN")
puts y.name
puts y.data.inspect
puts y.valid?

exit

# try a nonexisting symbol

y = YahooQuote.new("Alwkjlkwadj")
puts y.name
puts y.data.inspect
puts y.valid?






url = "http://finance.yahoo.com/d/quotes.csv?s=AMZN&f=snd1l1yr"
puts `curl -sL '#{url}'`

url = "http://finance.yahoo.com/d/quotes.csv?s=AMZN&f=snd1l1yr"
puts `curl -sL '#{url}'`

url = "http://ichart.finance.yahoo.com/t?s=%5AMZN"
#puts `curl -sL '#{url}'` # => outputs a png file



"XOM","Exxon Mobil Corpo","7/8/2011",82.42,2.17,11.73
"BBD-B.TO","BOMBARDIER INC., ","7/8/2011",6.76,1.12,15.60
"JNJ","Johnson & Johnson","7/8/2011",67.57,3.22,15.40
"MSFT","Microsoft Corpora","7/8/2011",26.92,2.28,10.64


2nd query:

"<img border=0  width=512 height=288
src="http://chart.yahoo.com/c/AMZN/a/amzn.gif" alt="Chart"><br><table><tr><td width=512 align=center><font face=arial size=-1></font></td></tr></table>"



"AMZN","Amazon.com, Inc.","7/8/2011",218.28,N/A,93.87
"MSFT","Microsoft Corpora","7/8/2011",26.92,2.28,10.64
"&nbsp;======&nbsp;"


"AMZN","Amazon.com, Inc.","7/8/2011",218.28,N/A,93.87
"MSFT","Microsoft Corpora","7/8/2011",26.92,2.28,10.64

"AMZN","Amazon.com, Inc.","7/8/2011",218.28,N/A,93.87
"MSFT","Microsoft Corpora","7/8/2011",26.92,2.28,10.64
"<img border=0  width=512 height=288
src="http://chart.yahoo.com/c//m/msft.gif" alt="Chart"><br><table><tr><td width=512 align=center><font face=arial size=-1></font></td></tr></table>","MSFT"

http://ichart.finance.yahoo.com/t?s=%5EHSI

"AMZN","Amazon.com, Inc.","7/8/2011",218.28,N/A,93.87
"MSFT","Microsoft Corpora","7/8/2011",26.92,2.28,10.64


