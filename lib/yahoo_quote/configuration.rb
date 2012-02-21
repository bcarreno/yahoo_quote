module YahooQuote
  class Configuration

    def self.cache_dir=(path)
      if !path
        @@cache_dir = path
      else
        dir = path.to_s
        Dir.mkdir(dir) unless dir.empty? || File.directory?(dir)
        @@cache_dir = dir
      end
    end

    def self.cache_dir
      @@cache_dir
    end

    @@cache_dir = nil
  end
end
