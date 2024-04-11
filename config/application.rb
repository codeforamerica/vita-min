require_relative "boot"
require_relative "../lib/middleware/cleanup_request_host_headers"
require_relative "../lib/middleware/cleanup_mime_type_headers"
require_relative "../lib/middleware/reject_invalid_params"
require_relative "../lib/middleware/reject_badly_encoded_headers"

require "logger"
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
    # Support Rails credentials key rotations https://abuisman.com/posts/rails/zero-downtime-credential-updates/
    if ENV.key?("RAILS_MASTER_KEY_NEW")
      logger = Logger.new($stdout)
      credential_path = Rails.root.join("config/credentials/#{Rails.env}.yml.enc")
      begin
        Rails.application.encrypted(credential_path, env_key: 'RAILS_MASTER_KEY_NEW').read
        ENV["RAILS_MASTER_KEY"] = ENV.delete("RAILS_MASTER_KEY_NEW")
        logger.info "application.rb: Using the new credential key, it works!"
      rescue ActiveSupport::MessageEncryptor::InvalidMessage
        logger.info "application.rb: Using the old key"
      end
    end

    config.load_defaults 7.0

    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]

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
    config.middleware.use Middleware::RejectBadlyEncodedHeaders
    config.gyr_current_tax_year = 2023
    config.ctc_current_tax_year = 2021
    config.statefile_current_tax_year = 2023
    config.product_year = 2024

    # These defaults can be overridden per-environment if needed
    # GetYourRefund
    config.start_of_unique_links_only_intake = Time.find_zone('America/Los_Angeles').parse('2024-01-24 12:00:00')
    config.start_of_open_intake = Time.find_zone('America/Los_Angeles').parse('2024-01-31 09:59:59')
    config.tax_deadline = Time.find_zone('America/New_York').parse('2024-04-18 23:59:59')
    config.end_of_intake = Time.find_zone('America/New_York').parse('2024-10-01 23:59:59')
    config.end_of_docs = Time.find_zone('America/New_York').parse('2024-4-01 23:59:59')
    config.end_of_in_progress_intake = Time.find_zone('America/New_York').parse('2024-10-16 23:59:59')
    config.end_of_login = Time.find_zone('America/New_York').parse('2024-10-23 23:59:00')

    # GetCTC
    config.ctc_soft_launch = Time.find_zone("America/New_York").parse("2022-05-04 09:00:00")
    config.ctc_full_launch = Time.find_zone("America/New_York").parse("2022-05-11 09:00:00")
    config.eitc_soft_launch = Time.find_zone("America/New_York").parse("2022-09-30 09:00:00")
    config.eitc_full_launch = Time.find_zone("America/New_York").parse("2022-10-11 09:00:00")
    config.ctc_end_of_intake = Time.find_zone("America/New_York").parse("2022-11-16 23:59:00")
    config.ctc_end_of_read_write = Time.find_zone("America/New_York").parse("2022-11-19 23:59:00")
    config.ctc_end_of_login = Time.find_zone("America/New_York").parse("2023-12-31 23:59:00")

    # StateFile
    config.state_file_start_of_open_intake = Time.find_zone('America/New_York').parse('2024-02-08 09:00:00')
    config.state_file_end_of_new_intakes = Time.find_zone('America/New_York').parse('2024-04-15 23:59:59')
    config.state_file_end_of_in_progress_intakes = Time.find_zone('America/New_York').parse('2024-04-25 23:59:59')

    config.allow_magic_verification_code = (Rails.env.demo? || Rails.env.development? || Rails.env.heroku?)
    config.allow_magic_ssn = (Rails.env.demo? || Rails.env.development? || Rails.env.heroku? || Rails.env.staging?)

    config.intercom_app_id = "rird6gz6"
    config.intercom_app_id_statefile = "rtcpj4hf"
    config.google_login_enabled = true

    # Add pdftk to PATH
    ENV['PATH'] += ":#{Rails.root}/vendor/pdftk"

    if ENV["RAILS_LOG_TO_STDOUT"].present?
      Rails.logger = ActiveSupport::Logger.new(STDOUT)
      Rails.logger.formatter = proc do |severity, timestamp, _progname, message|
        log_line =
          if message.is_a? Hash
            # When messages go through lograge, they arrive here as a Hash
            message
          else
            { message: message, level: severity, time: timestamp }
          end
        "#{log_line.to_json}\n"
      end
    end
  end
end
