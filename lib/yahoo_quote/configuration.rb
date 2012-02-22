module YahooQuote
  class Configuration

    def self.cache_dir=(path)
      if !path || path.to_s.empty?
        @@cache_dir = nil
      else
        path = Pathname.new(path) if path.is_a? String
        path.mkdir unless path.directory?
        @@cache_dir = path
      end
    end

    def self.cache_dir
      @@cache_dir
    end

    @@cache_dir = nil
  end
end
