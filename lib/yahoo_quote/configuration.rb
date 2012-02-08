module YahooQuote
  class Configuration

    def self.cache_dir=(path)
      dir = path.to_s
      Dir.mkdir(dir) unless File.directory?(dir)
      @@cache_dir = dir
    end

    def self.cache_dir
      @@cache_dir
    end

    @@cache_dir = nil
  end
end
