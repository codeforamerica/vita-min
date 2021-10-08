require_relative 'boot'
require_relative "../lib/middleware/cleanup_mime_type_headers"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module VitaMin
  class Application < Rails::Application
    config.load_defaults 6.0

    config.i18n.default_locale = :en
    config.i18n.fallbacks = [I18n.default_locale]
    config.i18n.available_locales = [:en, :es]

    config.active_job.queue_adapter = :delayed_job
    config.action_view.automatically_disable_submit_tag = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    #
    config.gyr_domains = {
      development: "localhost",
      demo: "demo.getyourrefund.org",
      staging: "staging.getyourrefund.org",
      production: "www.getyourrefund.org"
    }
    config.ctc_domains = {
      development: "ctc.localhost",
      demo: "ctc.demo.getyourrefund.org",
      staging: "ctc.staging.getyourrefund.org",
      production: "www.getctc.org"
    }
    config.middleware.use Middleware::CleanupMimeTypeHeaders

    # Logs are typically also available in log/{environment}.log
    if ENV["RAILS_LOG_TO_STDOUT"].present?
      config.rails_semantic_logger.add_file_appender = false
    end
    # Set LOG_FORMAT=json for production-style logging
    config.rails_semantic_logger.format = ENV.fetch("LOG_FORMAT", "color").to_sym
    config.semantic_logger.add_appender(io: $stdout, formatter: config.rails_semantic_logger.format)
  end
end
