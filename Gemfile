source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
gem 'responders', '~> 2.0'
gem 'sinatra'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'lodash-rails'
gem "font-awesome-rails"

gem 'tubesock'
gem 'event_bus'
gem 'redis'
gem 'color'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbograft', '0.1.16'
gem 'twine-rails', '0.0.16'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development
#gem 'thin'
gem 'puma'
gem 'pg'
gem 'rb-readline'
gem 'uuid'
gem 'mocha'
gem 'chronic_duration'
gem 'timecop'
gem 'mini_magick'
#gem 'pHash'
gem 'ffi'
gem 'thepiratebay', github: "qq99/thepiratebay", branch: "master"

gem 'foreman'
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem "sidekiq-cron", "~> 0.2.0"
gem "transmission_api", github: "qq99/TransmissionApi", branch: "master"

group :production, :development do
  gem 'hue', github: "qq99/hue", branch: "master"
  gem 'guard'
  gem 'guard-minitest'
end

group :test do
  gem 'webmock'
  gem "vcr"
end

group :development, :test do
  gem 'byebug'
  gem 'pry-rails'
  gem 'bond'
  gem 'pry-byebug'
  gem 'pry-theme'
  gem 'partially_useful'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'quiet_assets'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
