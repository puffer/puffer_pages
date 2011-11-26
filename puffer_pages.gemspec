# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "puffer_pages/version"

Gem::Specification.new do |s|
  s.name        = "puffer_pages"
  s.version     = PufferPages::VERSION
  s.authors     = ["pyromaniac"]
  s.email       = ["kinwizard@gmail.com"]
  s.homepage    = "http://github.com/puffer/puffer_pages"
  s.summary     = %q{Content Management System}
  s.description = %q{Puffer pages is integratable rails CMS with puffer admin interface}

  s.rubyforge_project = "puffer_pages"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_runtime_dependency(%q<rails>, ["~> 3.1.0"])
  s.add_runtime_dependency(%q<puffer>, [">= 0"])
  s.add_runtime_dependency(%q<liquid>, [">= 0"])
  s.add_runtime_dependency(%q<nested_set>, [">= 0"])

  s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
  s.add_development_dependency(%q<pg>, [">= 0"])
  s.add_development_dependency(%q<mysql>, [">= 0"])
  s.add_development_dependency(%q<rspec-rails>, [">= 0"])
  s.add_development_dependency(%q<capybara>, [">= 0.4.0"])
  s.add_development_dependency(%q<database_cleaner>, [">= 0"])
  s.add_development_dependency(%q<forgery>, [">= 0"])
  s.add_development_dependency(%q<fabrication>, [">= 0"])
  
  s.add_development_dependency(%q<guard>, [">= 0"])
  s.add_development_dependency(%q<guard-rspec>, [">= 0"])
  s.add_development_dependency(%q<libnotify>, [">= 0"])
  s.add_development_dependency(%q<rb-inotify>, [">= 0"])
end
