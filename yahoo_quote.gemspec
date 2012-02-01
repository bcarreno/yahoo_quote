# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yahoo_quote/version"

Gem::Specification.new do |s|
  s.name        = "yahoo_quote"
  s.version     = YahooQuote::VERSION
  s.authors     = ["Braulio Carreno"]
  s.email       = ["bcarreno@yahoo.com"]
  s.homepage    = ""
  s.summary     = %q{Yahoo stock quotes}
  s.description = %q{Yahoo stock quotes}

  s.add_dependency "nokogiri"
  s.add_development_dependency "fakeweb"

  s.rubyforge_project = "yahoo_quote"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
