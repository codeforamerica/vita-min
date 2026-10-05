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

    config.load_defaults 8.1

    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]

    # Added for Rails 7.2 upgrade:
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    # config.autoload_lib(ignore: %w[assets tasks]) # Rails 7.2 default
    config.autoload_lib(ignore: %w[assets tasks generators])
    # End of Rails 7.2 addition

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

    config.ctc_current_tax_year = 2021
    config.statefile_current_tax_year = 2024
    config.product_year = 2026

    pt = Time.find_zone('America/Los_Angeles')
    et = Time.find_zone('America/New_York')

    # These defaults can be overridden per-environment if needed
    # GetYourRefund
    config.start_of_unique_links_only_intake = pt.parse('2026-01-20 09:59:59')
    config.start_of_open_intake = pt.parse('2026-01-27 09:59:59')
    config.tax_deadline = et.parse('2026-04-15 23:59:59')
    config.end_of_intake = et.parse('2026-10-01 23:59:59')
    config.end_of_docs = et.parse('2026-10-08 23:59:59')
    # Per GYR1-994 changing doc_submission_deadline frm 2026-04-01 to 2026-04-06
    config.doc_submission_deadline = et.parse('2026-04-06 23:59:59')
    config.end_of_closing = et.parse('2026-10-15 23:59:59')
    config.end_of_in_progress_intake = et.parse('2026-10-15 23:59:59')
    config.end_of_login = et.parse('2026-10-23 23:59:00')

    config.tax_year_filing_seasons = {
      2025 => [et.parse("2026-01-29 00:00:00"), et.parse("2026-04-15 23:59:59")],
      2024 => [et.parse("2025-01-29 00:00:00"), et.parse("2025-04-15 23:59:59")],
      2023 => [et.parse("2024-01-29 00:00:00"), et.parse("2024-04-15 23:59:59")],
      2022 => [et.parse("2023-01-23 00:00:00"), et.parse("2023-04-18 23:59:59")],
      2021 => [et.parse("2022-01-24 00:00:00"), et.parse("2022-04-18 23:59:59")],
      2020 => [et.parse("2021-02-12 00:00:00"), et.parse("2021-05-17 23:59:59")],
      2019 => [et.parse("2020-01-27 00:00:00"), et.parse("2020-07-15 23:59:59")],
      2018 => [et.parse("2019-01-28 00:00:00"), et.parse("2019-04-15 23:59:59")],
      2017 => [et.parse("2018-01-29 00:00:00"), et.parse("2018-04-17 23:59:59")],
      2016 => [et.parse("2017-01-23 00:00:00"), et.parse("2017-04-18 23:59:59")],
      2015 => [et.parse("2016-01-19 00:00:00"), et.parse("2016-04-18 23:59:59")]
    }

    # GetCTC
    config.ctc_soft_launch = et.parse("2022-05-04 09:00:00")
    config.ctc_full_launch = et.parse("2022-05-11 09:00:00")
    config.eitc_soft_launch = et.parse("2022-09-30 09:00:00")
    config.eitc_full_launch = et.parse("2022-10-11 09:00:00")
    config.ctc_end_of_intake = et.parse("2022-11-16 23:59:00")
    config.ctc_end_of_read_write = et.parse("2022-11-19 23:59:00")
    config.ctc_end_of_login = et.parse("2024-12-31 23:59:00")

    # StateFile
    config.state_file_start_of_open_intake = et.parse('2025-01-15 00:00:00')
    config.state_file_tax_deadline = et.parse('2025-04-15 23:59:59')
    config.state_file_end_of_new_intakes = et.parse('2025-10-22 23:59:59')
    config.state_file_end_of_in_progress_intakes = et.parse('2025-10-31 23:59:59')
    config.state_file_show_faq_date_start = pt.parse('2024-12-10 00:00:00')
    config.state_file_show_faq_date_end = pt.parse('2025-11-15 23:59:59')

    config.allow_magic_verification_code = (Rails.env.demo? || Rails.env.development? || Rails.env.heroku? || Rails.env.staging?)
    config.allow_magic_ssn = (Rails.env.demo? || Rails.env.development? || Rails.env.heroku? || Rails.env.staging?)

    config.intercom_app_id = "rird6gz6"
    config.intercom_app_id_statefile = "rtcpj4hf"
    config.google_login_enabled = true

    config.x.simple_file_url = ENV.fetch("SIMPLE_FILE_BASE_URL", "https://staging.simplefile.getyourrefund.org")

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

    # ------------------------------------------------ #
    # BEGIN additions for Rails 7.1 defaults migration #
    # ------------------------------------------------ #

    # For reference, latest version of 7.1 defaults guidance is here:
    # https://github.com/rails/rails/blob/v7.1.6/railties/lib/rails/generators/rails/app/templates/config/initializers/new_framework_defaults_7_1.rb.tt

    # We depart from Rails 7.1 defaults here by *keeping* the `X-Download-Options`
    # key-value pair in order to continue supporting IE (only IE uses it).
    Rails.application.config.action_dispatch.default_headers = {
      "X-Frame-Options" => "SAMEORIGIN",
      "X-XSS-Protection" => "0",
      "X-Content-Type-Options" => "nosniff",
      "X-Download-Options" => "noopen",  # <--- Let's keep.
      "X-Permitted-Cross-Domain-Policies" => "none",
      "Referrer-Policy" => "strict-origin-when-cross-origin"
    }

    # Setting this to `false` ensures our Mixpanel/etc. PII filtering works.
    # E.g., spec/controllers/questions/consent_controller_spec.rb:70
    # (7.1 default is to set this to `true`.)
    Rails.application.config.precompile_filter_parameters = false

    # Set to `true` b/c we already use field-level encryption (guidance says set to
    # `false` if *not*.)
    Rails.application.config.active_record.encryption.support_sha1_for_non_deterministic_encryption = true

    # When `false` (the 7.1 default), path-loading issues seem to occur; so
    # keep `true` for now.
    Rails.application.config.add_autoload_paths_to_load_path = true

    # ------------------------------------------------ #
    #  END additions for Rails 7.1 defaults migration  #
    # ------------------------------------------------ #

    # ------------------------------------------------ #
    # BEGIN additions for Rails 7.2 defaults migration #
    # ------------------------------------------------ #

    # Reference:
    # https://github.com/rails/rails/blob/v7.2.3.2/railties/lib/rails/generators/rails/app/templates/config/initializers/new_framework_defaults_7_2.rb.tt

    # 7.2 defaults to including 'image/webp' as well here, but let's leave it
    # out (the earlier behavior we'll keep is for webp files to be converted to png).
    # - Not all browsers support the WebP format
    # - It would require imagemagick/libvips built with WebP support
    #   (juice might not be worth the squeeze).
    Rails.application.config.active_storage.web_image_content_types = %w[image/png image/jpeg image/gif]

    # ------------------------------------------------ #
    #  END additions for Rails 7.2 defaults migration  #
    # ------------------------------------------------ #

    # ------------------------------------------------ #
    # BEGIN additions for Rails 8.0 defaults migration #
    # ------------------------------------------------ #

    # Reference:
    # https://github.com/rails/rails/blob/v8.0.5.1/railties/lib/rails/generators/rails/app/templates/config/initializers/new_framework_defaults_8_0.rb.tt
    #
    # `load_defaults 8.0` sets exactly two things (see
    # railties/lib/rails/application/configuration.rb):
    #
    #   action_dispatch.strict_freshness = true
    #   Regexp.timeout ||= 1
    #
    # We accept `strict_freshness` as-is. It only changes behavior when a request
    # carries both `If-Modified-Since` and `If-None-Match` (the new default considers
    # only `If-None-Match`, per RFC 7232 section 6), and we do not use conditional GET
    # anywhere -- no `fresh_when`, `stale?`, `etag:` or `last_modified:` in app/ or lib/.

    # `Regexp.timeout` is process-global, so it applies to every regex in the app and in
    # every gem, not just our own code. It was measured before adopting: all 24,330
    # regexes device_detector ships (it runs on the user-controlled User-Agent for every
    # request via ApplicationController#user_agent and MixpanelService) were matched
    # against adversarial inputs -- 194,640 matches, zero Regexp::TimeoutError, 6.5ms
    # worst case. So 1s has roughly 150x headroom, and the rest of the app has only a
    # handful of short regexes and none applied to file contents.
    #
    # Starting at 5s rather than the 1s default anyway, as a staged rollout: the
    # measurement cannot cover a slow regex inside a gem that only production traffic
    # shapes reach. Tighten this to 1 (or delete the line to inherit the default) after
    # one release with no Regexp::TimeoutError in Sentry.
    Regexp.timeout = 5

    # ------------------------------------------------ #
    #  END additions for Rails 8.0 defaults migration  #
    # ------------------------------------------------ #

    # ------------------------------------------------ #
    # BEGIN additions for Rails 8.1 defaults migration #
    # ------------------------------------------------ #

    # Reference:
    # https://github.com/rails/rails/blob/v8.1.3.1/railties/lib/rails/generators/rails/app/templates/config/initializers/new_framework_defaults_8_1.rb.tt
    #
    # No departures. `load_defaults 8.1` sets seven things and all were checked against
    # this codebase before adopting; notes below so the reasoning is not lost.
    #
    # yjit = !Rails.env.local?
    #   YJIT in production/staging/demo/heroku. NOTE: the local rbenv Ruby on arm64
    #   darwin is built WITHOUT YJIT (`defined?(RubyVM::YJIT)` is nil), so this is a
    #   no-op locally and the test suite cannot exercise it. The deployed Ruby comes
    #   from the official `ruby:3.4.10` image, which does ship YJIT, so it engages
    #   there. Watch RSS and p95 latency in Datadog on the first deploy.
    #
    # action_controller.escape_json_responses = false
    #   Affects the `render json:` renderer, which we use in exactly two places
    #   (hub/campaign_messages/monitor_sms_controller and monitor_emails_controller),
    #   both consumed by JS rather than interpolated into markup.
    #   `<%= raw x.to_json %>` inside <script> blocks is a *different* code path and is
    #   still guarded by `ActiveSupport.escape_html_entities_in_json`, which stays true
    #   and continues to escape `</script>` to `</script>`.
    #
    # action_controller.action_on_path_relative_redirect = :raise
    #   Raises instead of logging for `redirect_to "example.com"` (no leading slash).
    #   No such redirect exists in app/ or lib/. Re-grep after a large rebase.
    #
    # active_record.raise_on_missing_required_finder_order_columns = true
    #   Only raises for models with no primary key, no implicit_order_column and no
    #   query_constraints. Verified by eager-loading every descendant: every
    #   table-backed model has a primary key or an order column.
    #
    # active_support.escape_js_separators_in_json = false
    #   Stops escaping U+2028/U+2029 in JSON. Valid inside JS string literals since
    #   ECMAScript 2019. The `raw ... to_json` script blocks carry county and
    #   municipality names from config and the database, not free text.
    #
    # action_view.render_tracker = :ruby
    #   Template dependency tracking for the development reloader.
    #
    # action_view.remove_hidden_field_autocomplete = true
    #   Drops `autocomplete="off"` from hidden inputs generated by form_tag/token_tag/
    #   method_tag/button_to. No spec asserts on hidden-field autocomplete, and hidden
    #   inputs render nothing visible, so the Percy snapshots are unaffected.

    # ------------------------------------------------ #
    #  END additions for Rails 8.1 defaults migration  #
    # ------------------------------------------------ #
  end
end
