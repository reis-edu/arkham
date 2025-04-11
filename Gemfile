source "https://rubygems.org"

ruby '3.4.2'

gem 'bcrypt'
gem "rails", "~> 8.0.2"
gem "propshaft"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem 'settingslogic'
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem 'dry-validation'
gem 'aws-sdk-s3'
gem 'jwt'
gem 'pg', '>= 0.18', '< 2.0'
gem 'rabl-rails'
gem 'vcr'
gem 'webmock'
gem 'rack-cors'

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 7.0.0'
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem 'faker'
  gem 'cpf_utils'
  gem 'timecop'
  gem "capybara"
  gem "selenium-webdriver"
end

gem "factory_bot", "~> 6.5"
