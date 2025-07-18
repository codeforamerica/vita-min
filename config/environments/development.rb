require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Emails are printed to the `rails jobs:work` console and logged to tmp/mail/#{to_address}
  config.action_mailer.raise_delivery_errors = true
  if ENV['LETTER_OPENER']
    config.action_mailer.delivery_method = :letter_opener
    config.action_mailer.perform_deliveries = true

    LetterOpener.configure do |config|
      config.file_uri_scheme = "file://"
    end
  else
    config.action_mailer.delivery_method = :file
  end
  config.action_mailer.logger = Logger.new(STDOUT)
  config.action_mailer.logger.level = Logger::DEBUG
  config.action_mailer.perform_caching = false

  ngrok_host = ENV["NGROK_HOST"] # for example: 'd90d61a5caf9.ngrok.io'
  ctc_email_from_domain = "ctc.localhost"
  gyr_email_from_domain = "localhost"
  statefile_email_from_domain = "statefile.localhost"
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
      statefile: "help@#{statefile_email_from_domain}"
    }
  }
  if ngrok_host.present?
    config.action_mailer.default_url_options = { protocol: 'https', host: ngrok_host, port: 80 }
  else
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  end
  Rails.application.default_url_options = config.action_mailer.default_url_options

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Use vita-min routes to render server error pages.
  config.exceptions_app = self.routes

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true
  config.i18n.available_locales = [:en, :es]

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Allow incoming connections over ngrok
  config.hosts << /[a-z0-9]+\.ngrok\.io/
  config.hide_ctc = false
  config.ctc_url = "http://ctc.localhost:3000"
  config.statefile_url = "http://statefile.localhost:3000"
  config.gyr_url = "http://localhost:3000"
  config.efile_environment = "test"

  # CTC
  config.ctc_soft_launch = Time.find_zone("America/New_York").parse("2022-03-01 09:00:00")
  config.ctc_full_launch = Time.find_zone("America/New_York").parse("2022-04-01 09:00:00")

  # StateFile
  config.state_file_start_of_open_intake = Time.find_zone('America/New_York').parse('2024-01-01 7:59:59')

  # Keep GYR and FYST 'open' until the end of 2040 ^_^
  # use the session toggles if you want to emulate/test 'closed' behaviors
  # use the year "2040" to test what it looks like between these milestones
  the_earlier_future = Time.find_zone('America/New_York').parse('2039-12-31 23:59:59')
  the_further_future = Time.find_zone('America/New_York').parse('2040-12-31 23:59:59')
  config.end_of_intake = the_further_future
  config.state_file_end_of_new_intakes = the_earlier_future
  config.state_file_end_of_in_progress_intakes = the_further_future
end
