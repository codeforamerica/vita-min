source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby_version = File.read(File.join(File.dirname(__FILE__), '.ruby-version')).strip
ruby ruby_version

gem 'rack', '>= 2.0.8'
gem 'rails', '~> 7.1'
gem 'puma', '>= 5.3.2'
gem 'sass-rails', '~> 5.0'
gem 'cfa-styleguide', '0.10.5', git: 'https://github.com/codeforamerica/honeycrisp-gem', branch: 'main', ref: '4c6f873f55704ec34fd518906f131133b290e56a'
gem 'nokogiri', '>= 1.10.8'
gem 'recaptcha'
gem "activerecord-cte" # Can be removed when we move to Rails 7.1

# Use ActiveStorage variant
gem 'image_processing'

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
gem 'device_detector', '~> 1.0.7' # 1.1+ causes test failures, investigate someday
gem 'mixpanel-ruby'
gem 'devise'
gem 'devise-i18n'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'lograge'
gem 'fix-db-schema-conflicts', require: false
gem 'valid_email2', '~> 4.0.6' # test failures on 5.x, try again if you're bold
gem 'auto_strip_attributes'
gem 'ddtrace', '~> 1.9.0'
gem 'dogapi'
gem 'http_accept_language'
gem 'rails-i18n'
gem 'thor'
gem 'websocket-extensions', '>= 0.1.5'
gem 'twilio-ruby'
gem 'mailgun-ruby'
gem 'devise_invitable'
gem 'cancancan'
gem 'shakapacker'
gem 'combine_pdf'
gem 'pdf-reader', '~> 2.4.1'
gem 'rails_autolink'
gem 'ice_nine'
gem 'business_time'
gem 'scenic'
gem 'rubyzip'
gem 'intercom', '4.1.3' # potential issue with 4.2.0
gem 'statesman'
gem 'redcarpet'
gem 'platform-api'
gem 'data_migrate'
gem 'strong_migrations'
gem 'zxcvbn-ruby', require: 'zxcvbn'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection', '~>1.0'
gem 'pycall'
gem 'acts_as_list'
gem 'paper_trail'
gem 'jwt'
gem 'method_source'
gem 'ordinalize_full'
gem 'awesome_print'
gem 'rack-attack'
gem 'airrecord'

# Use Flipper for feature flagging
gem 'flipper'
gem 'flipper-active_record'
gem 'flipper-ui'

group :demo, :development, :test do
  gem 'factory_bot_rails' # added to demo for creating fake data
end

group :demo, :development, :heroku, :staging, :production do
  # for storing results of rack-mini-profiler
  gem 'redis'

  gem 'rack-mini-profiler'
end

group :development, :test do
  gem 'annotate'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'axe-matchers'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'pry-byebug'
  gem 'guard-rspec', require: false
  gem 'rubocop', '~> 1.46.0', require: false
  gem 'rubocop-performance', '~> 1.16.0', require: false
  gem 'rubocop-rspec', '~> 2.18.0', require: false
  gem 'i18n-tasks', require: false
  gem 'easy_translate'
  gem 'bundle-audit'
  gem 'parallel_tests'
  gem 'turbo_tests'
  gem 'timecop'
  gem 'warning', require: false
  gem 'rspec_junit_formatter'
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
  gem 'webmock'
  gem 'simplecov', require: false
  gem 'shoulda-matchers'
  gem 'spring-commands-rspec'
  gem 'database_cleaner'
  gem 'percy-capybara'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
