require_relative "boot"
require_relative "../lib/middleware/cleanup_request_host_headers"
require_relative "../lib/middleware/cleanup_mime_type_headers"
require_relative "../lib/middleware/reject_invalid_params"

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
    config.load_defaults 7.0

    config.active_record.enumerate_columns_in_select_statements = true
    config.active_storage.variant_processor = :mini_magick

    # The new Rails default is SHA256 but we would need to write a rotator
    # to ensure nobody gets logged out, so let's stick with the old one for now.
    config.active_support.hash_digest_class = OpenSSL::Digest::SHA1

    # The new default is 'true'; this can be removed if someone verifies
    # that all our buttons will work fine as <button> rather than <input>
    config.action_view.button_to_generates_button_tag = false

    config.i18n.default_locale = :en
    config.i18n.fallbacks = [I18n.default_locale]
    config.i18n.available_locales = [:en, :es]

    config.action_mailer.deliver_later_queue_name = 'mailers'
    config.ssl_options = { redirect: { exclude:
                                         ->(request) do
                                           # Aptible's internal health check needs to bypass Rails HTTPS upgrade so it returns 200 OK
                                           request.path == "/healthcheck" ||
                                             # Identrust EV certificate validation requires HTTP not HTTPS;
                                             # must disable Aptible HTTPS redirect for this, see https://deploy-docs.aptible.com/docs/https-redirect
                                             request.path.to_s.start_with?("/.well-known/pki-validation/")
                                         end
    } }

    config.active_job.queue_adapter = :delayed_job
    config.action_view.automatically_disable_submit_tag = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    #
    #
    config.middleware.use Middleware::CleanupRequestHostHeaders
    config.middleware.use Middleware::CleanupMimeTypeHeaders
    config.middleware.use Middleware::RejectInvalidParams
    config.gyr_current_tax_year = 2022
    config.ctc_current_tax_year = 2021

    # These defaults can be overridden per-environment if needed
    config.start_of_unique_links_only_intake = Time.find_zone('America/Los_Angeles').parse('2022-01-24 09:59:59')
    config.start_of_open_intake = Time.find_zone('America/Los_Angeles').parse('2022-01-31 09:59:59')
    config.end_of_intake = Time.find_zone('America/New_York').parse('2022-10-01 23:59:59')
    config.end_of_login = Time.find_zone('America/New_York').parse('2022-10-15 23:59:00')

    config.ctc_soft_launch = Time.find_zone("America/New_York").parse("2022-05-04 09:00:00")
    config.ctc_full_launch = Time.find_zone("America/New_York").parse("2022-05-11 09:00:00")
    config.eitc_soft_launch = Time.find_zone("America/New_York").parse("2022-09-30 09:00:00")
    config.eitc_full_launch = Time.find_zone("America/New_York").parse("2022-10-11 09:00:00")
    config.ctc_end_of_intake = Time.find_zone("America/New_York").parse("2022-11-16 23:59:00")
    config.ctc_end_of_login = Time.find_zone("America/New_York").parse("2022-11-19 23:59:00")

    config.allow_magic_verification_code = (Rails.env.demo? || Rails.env.development? || Rails.env.heroku?)
  end
end
