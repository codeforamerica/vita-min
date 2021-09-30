Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
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
  else
    config.action_mailer.delivery_method = :file
  end
  config.action_mailer.logger = Logger.new(STDOUT)
  config.action_mailer.logger.level = Logger::DEBUG
  config.action_mailer.perform_caching = false

  ngrok_host = ENV["NGROK_HOST"] # for example: 'd90d61a5caf9.ngrok.io'
  ctc_email_from_domain = "ctc.localhost"
  gyr_email_from_domain = "localhost"
  config.email_from = {
    default: {ctc: "hello@#{ctc_email_from_domain}", gyr: "hello@#{gyr_email_from_domain}"},
    noreply: {ctc: "no-reply@#{ctc_email_from_domain}", gyr: "no-reply@#{gyr_email_from_domain}"}
  }
  if ngrok_host.present?
    config.action_mailer.default_url_options = { protocol: 'https', host: ngrok_host, port: 80 }
  else
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  end
  Rails.application.default_url_options = config.action_mailer.default_url_options

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Use vita-min routes to render server error pages.
  config.exceptions_app = self.routes

  # Raises error for missing translations.
  config.action_view.raise_on_missing_translations = true
  config.i18n.available_locales = [:en, :es]


  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Allow incoming connections over ngrok
  config.hosts << /[a-z0-9]+\.ngrok\.io/
  config.offseason = true
  config.hide_ctc = false
  config.forward_intercom_messages = false
  config.ctc_url = "ctc.localhost:3000"
  config.gyr_url = "localhost:3000"
  config.efile_environment = ""
end
