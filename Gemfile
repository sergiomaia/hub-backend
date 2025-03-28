source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem 'pg'
gem 'connection_pool'
gem 'sorbet-runtime'

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem 'sorbet'
end

group :test do
  gem 'mocha'
end
