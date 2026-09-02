source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby_version = File.read(File.join(File.dirname(__FILE__), '.ruby-version')).strip
ruby ruby_version

plugin 'bootboot', '~> 0.2.2'

# `plugin` above only declares/installs bootboot; it has to be loaded here for its
# Bundler::Dsl patch (which defines `enable_dual_booting`) to exist while this Gemfile
# is being evaluated.
Plugin.send(:load_plugin, 'bootboot') if Plugin.installed?('bootboot')

# Required for the "next" boot to read Gemfile_next.lock instead of Gemfile.lock.
# bootboot patches Bundler::Definition only when this is called, so without it
# `DEPENDENCIES_NEXT=1 bundle install` resolves the next Gemfile against the *primary*
# lockfile and fails with a version conflict.
enable_dual_booting if ENV['DEPENDENCIES_NEXT'] && Plugin.installed?('bootboot')

# Declares a gem that differs between the primary boot and the bootboot "next" boot.
#
# The env var must match bootboot's own: it is `Bundler.settings["bootboot_env_prefix"]`
# (default "DEPENDENCIES") + "_NEXT". Keying this on anything else -- e.g. plain `NEXT`
# -- means bootboot regenerates Gemfile_next.lock without taking the next branch, and
# the two lockfiles come out identical.
# `versions` and `next_version` each accept one or more requirement strings, so a
# multi-part constraint like ('~> 10.0', '>= 10.0.2') survives the round trip.
def gemn(gem_name, *versions, next_version: nil, next_name: nil, **kwargs)
  if next_version && ENV['DEPENDENCIES_NEXT']
    gem(next_name || gem_name, *Array(next_version), **kwargs)
  else
    gem gem_name, *versions, **kwargs
  end
end

gem 'rack', '>= 3.2.6'
gemn 'rails', '~> 7.2.3.1', next_version: '~> 8.0.5'
# Transitive only (railties/activesupport both say `minitest >= 5.1`; this is an RSpec
# suite). Held at 5.x so the Rails 8 boot does not also cross a minitest major.
# Drop this pin once the upgrade has landed -- see the Rails 8 upgrade plan, Phase 7.
gem 'minitest', '~> 5.27'
gem 'puma', '>= 7.2.1'
gem 'sass-rails', '~> 6.0'
gem 'cfa-styleguide', '0.17.1', git: 'https://github.com/codeforamerica/honeycrisp-gem', branch: 'main', ref: '40a4356dd217dacfba82a7b92010111999954c91'
gem 'nokogiri', '>= 1.19.3'
gem 'recaptcha'
gem 'airrecord'

# Use ActiveStorage variant
gem 'image_processing', '>= 2.0.3'
gem "mini_magick", "~> 5.0" # Used by image_processing

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.5.1', require: false
gem 'phony'
gem 'pg'
gem 'pg_search'
# Pins to one Rails minor at a time: 10.0.x => AR 7.2, 11.0.x => AR 8.0, 11.1.x => AR 8.1
gemn 'activerecord-postgis-adapter', '~> 10.0', '>= 10.0.2', next_version: '~> 11.0.0'
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
gem 'bcrypt', '>= 3.1.22'
gem 'devise-i18n'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'delayed_job'
gem 'lograge'
gem 'fix-db-schema-conflicts', require: false
gem 'valid_email2', '~> 4.0.6' # test failures on 5.x, try again if you're bold
gem 'auto_strip_attributes'
gem 'datadog', '~> 2.41.0', require: 'datadog/auto_instrument'
gem 'dogapi'
gem 'http_accept_language'
gem 'rails-i18n'
gem 'thor'
gem 'websocket-extensions', '>= 0.1.5'
gem "twilio-ruby", "~> 7.10"
gem 'mailgun-ruby'
gem 'devise_invitable'
gem 'cancancan'
gem 'shakapacker', '9.7.0'
gem 'combine_pdf'
gem 'pdf-reader', '~> 2.4.1'
gem 'rails_autolink'
gem 'ice_nine'
gem 'business_time'
gem 'rubyzip'
gem 'intercom', '4.1.3' # potential issue with 4.2.0
gem 'statesman'
gem 'redcarpet'
gem 'platform-api'
gem 'data_migrate', '>= 10.0'
gem 'strong_migrations'
gem 'zxcvbn-ruby', require: 'zxcvbn'
gem 'omniauth'
gem "omniauth-google-oauth2", "~> 1.2"
gem 'omniauth-rails_csrf_protection', '~>1.0'
gem 'openssl-oaep'
gem 'pycall'
gem 'acts_as_list'
gem 'paper_trail', '~> 17.0'
gem "jwt", ">= 3.2.0"
gem 'method_source'
gem 'ordinalize_full'
gem 'awesome_print'
gem 'holidays'
gem "net-imap", ">= 0.6.4"
gem 'redis'
gem "observer", "~> 0.1.2"
gem "csv", "~> 3.3"
gem "rexml", ">= 3.4.2"
gem 'useragent'

# Use Flipper for feature flagging
gem 'flipper'
gem 'flipper-active_record'
gem 'flipper-ui'

group :demo, :development, :test do
  gem 'factory_bot_rails' # added to demo for creating fake data
end

group :demo, :development, :heroku, :staging do
  gem 'rack-mini-profiler'
end

group :development, :test do
  gem 'annotaterb', '4.23.0'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'axe-core-rspec'
  gem 'axe-core-capybara'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'pry-byebug'
  gem 'guard-rspec', require: false
  gem 'rubocop', '~> 1.53.0', require: false
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
  gem 'dotenv'
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
  gem "faraday", ">= 2.14.2"
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

gem "pundit", "~> 2.5"

gem "openssl", ">= 3.3.1"

gem "aws-sdk-core", "~> 3.190"

gem "aws-sdk-bedrockruntime", "~> 1.2"

gem 'oauth2', '>= 2.0.22'
