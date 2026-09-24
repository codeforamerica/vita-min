require "concurrent/set"

class EnvironmentCredentials
  # Some variables don't map obviously.
  SECRET_KEYS = {
    'VITA_MIN_EFIN' => [:irs, :efin],
    'MD_SIN' => [:irs, :md_sin],
    'VITA_MIN_SIN' => [:irs, :sin],
    'GYR_EFILER_CERT' => [:irs, :efile_cert_base64],
    'GYR_EFILER_ETIN' => [:irs, :etin],
    'GYR_EFILER_APP_SYS_ID' => [:irs, :app_sys_id],
    'INTERCOM_ACCESS_TOKEN' => [:intercom, :intercom_access_token]
  }.freeze

  REPORTED_CREDENTIALS_READS = Concurrent::Set.new

  class << self
    def [](name)
      
      if Flipper.enabled?(:use_env_secrets)
        ENV.fetch(name, nil)
      else
        credentials_value(name)
      end
    rescue ActiveRecord::ActiveRecordError
      # Necessary when starting from scratch because flipper tables are not
      # established yet
      ENV.fetch(name, nil) || credentials_value(name)
    end

    def dig(*keys)
      Rails.application.credentials.dig(*keys)
    end

    def irs(key)
      env_var_names = {
        efile_cert_base64: 'GYR_EFILER_CERT',
        etin: 'GYR_EFILER_ETIN',
        app_sys_id: 'GYR_EFILER_APP_SYS_ID',
        efin: 'VITA_MIN_EFIN',
        md_sin: 'MD_SIN',
        sin: 'VITA_MIN_SIN',
      }
      from_env = ENV[env_var_names[key]].presence
      return from_env if from_env

      dig(:irs, key).tap do |value|
        report_credentials_read(env_var_names[key] || "irs.#{key}") if value.present?
      end
    end

    private

    # reports if values came from creds file instead of ENV variable
    def credentials_value(name)
      lookup_in_credentials(name).tap do |value|
        report_credentials_read(name) if value.present?
      end
    end

    def report_credentials_read(name)
      return unless defined?(Sentry) && Sentry.initialized?
      return unless REPORTED_CREDENTIALS_READS.add?(name)

      in_env = ENV[name].present?
      Sentry.capture_message(
        "EnvironmentCredentials: #{name} came from the credentials file " \
        "(#{in_env ? 'also present in ENV' : 'MISSING from ENV'})",
        level: in_env ? :info : :warning
      )
    end

    # Imperfectly attempts to find keys within credentials, if the credential
    # isn't found in the SECRET_KEYS hash map. Note, this means that FOO_BAR_BAZ
    # will first match dig(:foo, :bar_baz) if it is present and will therefore
    # not match dig(:foo, :bar, :baz)
    def lookup_in_credentials(name)
      return dig(*SECRET_KEYS[name]) if SECRET_KEYS.key?(name)

      keys = []
      string = name.downcase

      value = dig(string.to_sym) 

      return value if value.present?

      while string.present?
        head, _, string = string.partition('_')

        keys << head.to_sym

        value = dig(*(keys + [string.to_sym]))

        return value if value.present?
      end
    # Catch when a value is found, but subsequent #dig calls will be on a type
    # other than a hash
    rescue TypeError
      nil
    end
  end
end
