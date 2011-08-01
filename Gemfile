source "http://rubygems.org"

gem 'rails', '>= 3.1.0.rc5'
gem 'puffer', :git => 'git://github.com/puffer/puffer.git'
gem 'liquid', :git => 'git://github.com/puffer/liquid.git'
gem 'nested_set'

group :development, :test, :pg_test do
  gem "sqlite3-ruby", :require => "sqlite3"
  gem "pg"
  gem "mysql"

  gem "rspec-rails"
  gem "capybara", ">= 0.4.0"
  gem 'database_cleaner'

  gem 'guard'
  gem 'libnotify'
  gem 'guard-rspec'

  gem 'forgery'
  gem 'fabrication'
  gem "jeweler"
end

