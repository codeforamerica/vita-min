source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rack', '>= 2.0.8'
gem 'rails', '>= 6.0.3'
gem 'puma', '>= 4.3.5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'cfa-styleguide', git: 'https://github.com/codeforamerica/cfa-styleguide-gem'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby
gem 'nokogiri', '>= 1.10.8'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
gem 'image_processing'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'arel_extensions'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'phonelib'
gem 'strip_attributes'
gem 'zendesk_api'
gem 'pg'
gem 'activerecord-postgis-adapter'
gem 'will_paginate'
gem 'sentry-raven'
gem 'pdf-forms'
gem 'aws-sdk-s3'
gem 'device_detector'
gem 'mixpanel-ruby'
gem 'devise'
gem 'devise-i18n'
gem 'omniauth-oauth2'
gem 'omniauth-rails_csrf_protection', '~> 0.1'
gem 'sendgrid-ruby'
gem 'delayed_job_active_record'
gem 'attr_encrypted'
gem 'lograge'
gem 'fix-db-schema-conflicts'
gem 'valid_email2'
gem 'auto_strip_attributes'
gem 'ddtrace'
gem 'dogapi'
gem 'http_accept_language'
gem 'rails-i18n'
gem 'thor'
gem 'websocket-extensions', '>= 0.1.5'
gem 'twilio-ruby', '~> 5.40.1'
gem 'mailgun-ruby', '~>1.1.6'
gem 'devise_invitable', '~> 2.0.0'
gem 'cancancan'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'axe-matchers'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'webdrivers'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'pry-byebug'
  gem 'guard-rspec', require: false
  gem 'rubocop', '~> 0.82.0', require: false
  gem 'rubocop-performance', '~> 1.5.2', require: false
  gem 'rubocop-rspec', '~> 1.38.1', require: false
  gem 'i18n-tasks', require: false
  gem 'easy_translate'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'git-pair'
  gem 'annotate'
end

group :test do
  gem 'rspec_junit_formatter'
  gem 'webmock'
  gem 'simplecov', require: false
  gem 'shoulda-matchers', '~> 4.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
