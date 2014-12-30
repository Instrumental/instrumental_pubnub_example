$:.push File.expand_path("../lib", __FILE__)
require "instrumental/pub_nub/version"

Gem::Specification.new do |s|
  s.name        = "instrumental_pubnub_example"
  s.version     = Instrumental::PubNub::VERSION
  s.authors     = ["Christopher Zelenak"]
  s.email       = ["support@instrumentalapp.com"]
  s.homepage    = "http://github.com/expectedbehavior/instrumental_pubnub_example"
  s.summary     = %q{Relay PubNub data to instrumentalapp.com}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency(%q<pubnub>, [">= 3.6.9"])
  s.add_dependency(%q<instrumental_agent>, [">= 0.12.7"])
  s.add_development_dependency(%q<rake>, [">= 0"])
end
