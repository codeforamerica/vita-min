source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rack', '>= 2.0.8'
gem 'rails', '>= 6.1.4.1'
gem 'puma', '>= 5.3.2'
gem 'sass-rails', '~> 5.0'
gem 'cfa-styleguide', '0.10.5', git: 'https://github.com/codeforamerica/honeycrisp-gem', branch: 'main'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', '~> 0.4.0', platforms: :ruby
gem 'nokogiri', '>= 1.10.8'
gem 'recaptcha'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
gem 'image_processing'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.5.1', require: false
gem 'phony'
gem 'pg'
gem 'pg_search'
gem 'activerecord-postgis-adapter'
gem 'will_paginate'
gem 'sentry-delayed_job'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'pdf-forms', '~> 1.3.0'
gem 'aws-sdk-s3'
gem 'aws-sdk-route53'
gem 'device_detector'
gem 'mixpanel-ruby'
gem 'devise'
gem 'devise-i18n'
gem 'delayed_job_active_record'
gem 'attr_encrypted'
gem 'lograge'
gem 'fix-db-schema-conflicts', require: false
gem 'valid_email2'
gem 'auto_strip_attributes'
gem 'ddtrace', '~> 0.41.0'
gem 'dogapi'
gem 'http_accept_language'
gem 'rails-i18n'
gem 'thor'
gem 'websocket-extensions', '>= 0.1.5'
gem 'twilio-ruby'
gem 'mailgun-ruby'
gem 'devise_invitable', '~> 2.0.0'
gem 'cancancan'
gem 'webpacker', '~> 5.4.0'
gem 'combine_pdf'
gem 'pdf-reader', '~> 2.4.1'
gem 'rails_autolink'
gem 'ice_nine'
gem 'business_time'
gem 'scenic'
gem 'rubyzip'
gem 'intercom', '~> 4.1'
gem 'statesman', '~> 8.0.3'
gem 'redcarpet'
gem 'platform-api'

group :demo, :development, :test do
  gem 'factory_bot_rails' # added to demo for creating fake data
  gem 'faker'
end

group :development, :test do
  gem 'awesome_print'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'axe-matchers'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'webdrivers'
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'pry-byebug'
  gem 'guard-rspec', require: false
  gem 'rubocop', '~> 0.82.0', require: false
  gem 'rubocop-performance', '~> 1.5.2', require: false
  gem 'rubocop-rspec', '~> 1.38.1', require: false
  gem 'i18n-tasks', require: false
  gem 'easy_translate'
  gem 'bundle-audit'
  gem 'parallel_tests'
  gem 'turbo_tests'
  gem 'timecop'
  gem 'warning', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.4.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'git-pair'
  gem 'annotate'
  gem 'rack-mini-profiler'
  gem 'flamegraph'
  gem 'stackprof'
  gem 'memory_profiler'
  gem "letter_opener"
end

group :test do
  gem 'rspec_junit_formatter'
  gem 'webmock'
  gem 'simplecov', require: false
  gem 'shoulda-matchers', '~> 4.3.0'
  gem 'spring-commands-rspec'
  gem 'database_cleaner'
  gem 'percy-capybara'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
