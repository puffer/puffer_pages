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
  s.add_runtime_dependency "rails", ">= 3.1"
  s.add_runtime_dependency "puffer"
  s.add_runtime_dependency "liquid"
  s.add_runtime_dependency "nested_set"
  s.add_runtime_dependency "activeuuid"
  s.add_runtime_dependency "contextuality"

  s.add_development_dependency "bcrypt-ruby"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pg"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "globalize3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "forgery"
  s.add_development_dependency "fabrication"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "timecop"
end
