require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = !ENV['RAILS_CACHE_CLASSES'].present? # possibly should only be 'true' for test env if spring is running

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV['EAGER_LOAD'].present? # in the base rails config ENV['CI'] is used here instead

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # ActiveJob
  config.active_job.queue_adapter = :test

  ctc_email_from_domain = "ctc.test.localhost"
  gyr_email_from_domain = "test.localhost"
  statefile_email_from_domain = "statefile.test.localhost"
  config.email_from = {
    default: {
      ctc: "hello@#{ctc_email_from_domain}",
      gyr: "hello@#{gyr_email_from_domain}",
      statefile: "hello@#{statefile_email_from_domain}"
    },
    noreply: {
      ctc: "no-reply@#{ctc_email_from_domain}",
      gyr: "no-reply@#{gyr_email_from_domain}",
      statefile: "no-reply@#{statefile_email_from_domain}"
    },
    support: {
      ctc: "support@#{ctc_email_from_domain}",
      gyr: "support@#{gyr_email_from_domain}",
      statefile: "support@#{statefile_email_from_domain}"
    }
  }

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  config.i18n.available_locales = [:en, :es]
  config.hide_ctc = false
  config.ctc_url = "http://ctc.test.localhost"
  config.statefile_url = "http://statefile.test.localhost"
  config.gyr_url = "http://test.localhost"
  config.signature_log_bucket = "vita-min-test-signatures"
  config.efile_environment = ""
  config.efile_security_information_for_testing = nil

  # Allow stub views for base controller classes https://stackoverflow.com/questions/5147734/rspec-stubing-view-for-anonymous-controller
  config.paths['app/views'] << "spec/test_views"

  # By default, intake is open in the test suite
  # GYR
  config.start_of_unique_links_only_intake = Time.find_zone('America/Los_Angeles').parse('2001-01-01 00:00:00')
  config.start_of_open_intake = Time.find_zone('America/Los_Angeles').parse('2001-01-01 00:00:00')
  config.end_of_intake = Time.find_zone('America/Los_Angeles').parse('2038-12-31 23:59:59')

  # StateFile
  config.state_file_start_of_open_intake = Time.find_zone('America/New_York').parse('2024-01-01 7:59:59')

  config.active_record.encryption.primary_key = 'test'
  config.active_record.encryption.deterministic_key = 'test'
  config.active_record.encryption.key_derivation_salt = 'test'
end
