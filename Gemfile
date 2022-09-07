source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby_version = File.read(File.join(File.dirname(__FILE__), '.ruby-version')).strip
ruby ruby_version

gem 'rack', '>= 2.0.8'
gem 'rails', '~> 7.0.3.1'
gem 'puma', '>= 5.3.2'
gem 'sass-rails', '~> 5.0'
gem 'cfa-styleguide', '0.10.5', git: 'https://github.com/codeforamerica/honeycrisp-gem', branch: 'main', ref: '4c6f873f55704ec34fd518906f131133b290e56a'
gem 'nokogiri', '>= 1.10.8'
gem 'recaptcha'

# Adding this removes some deprecation warnings, caused by double-loading of the net-protocol library
# (see https://github.com/ruby/net-imap/issues/16)
# we *might* be able to remove this after upgrading to Ruby 3
gem 'net-http'
gem 'uri', '0.10.0' # force us to get the default version from Ruby 2.7

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
gem 'lograge'
gem 'fix-db-schema-conflicts', require: false
gem 'valid_email2'
gem 'auto_strip_attributes'
gem 'ddtrace', '~> 1.0.0'
gem 'dogapi'
gem 'http_accept_language'
gem 'rails-i18n'
gem 'thor'
gem 'websocket-extensions', '>= 0.1.5'
gem 'twilio-ruby'
gem 'mailgun-ruby'
gem 'devise_invitable', '2.0.5' # 2.0.6 causes a test failure in ./spec/controllers/users/invitations_controller_spec.rb:395 thanks to https://github.com/scambra/devise_invitable/commit/986f49b1625592c4622a99b6cfb6073b1a234b7c; bump devise_invitable and fix the test someday
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
gem 'statesman', '~> 9.0'
gem 'redcarpet'
gem 'platform-api'
gem 'strong_migrations'
gem 'fraud-gem', git: 'https://github.com/codeforamerica/fraud-gem.git', tag: 'v1.0.5', require: ["fraud_gem"]

# Use Flipper for feature flagging
gem 'flipper'
gem 'flipper-active_record'
gem 'flipper-ui'

group :demo, :development, :test do
  gem 'factory_bot_rails' # added to demo for creating fake data
  gem 'faker'
end

group :demo, :development, :heroku, :staging do
  gem 'rack-mini-profiler'
end

group :development, :test do
  gem 'annotate'
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
  gem 'git-pair'
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
