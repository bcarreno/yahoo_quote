module YahooQuote
  class Configuration

    def self.cache_dir=(dir)
      @@cache_dir = dir
    end

    def self.cache_dir
      @@cache_dir
    end

    @@cache_dir = "/tmp"
  end
end
