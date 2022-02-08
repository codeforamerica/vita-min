require_relative "boot"
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
    config.load_defaults 6.1

    config.i18n.default_locale = :en
    config.i18n.fallbacks = [I18n.default_locale]
    config.i18n.available_locales = [:en, :es]

    config.action_mailer.deliver_later_queue_name = 'mailers'

    config.active_job.queue_adapter = :delayed_job
    config.action_view.automatically_disable_submit_tag = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    #
    config.middleware.use Middleware::CleanupMimeTypeHeaders
    config.current_tax_year = 2021

    # These defaults can be overridden per-environment if needed
    config.start_of_unique_links_only_intake = Time.find_zone('America/Los_Angeles').parse('2022-01-24 09:59:59')
    config.start_of_open_intake = Time.find_zone('America/Los_Angeles').parse('2022-01-31 09:59:59')
    config.end_of_intake = Time.find_zone('America/Los_Angeles').parse('2022-08-31 23:59:59')
  end
end
