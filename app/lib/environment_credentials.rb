class EnvironmentCredentials
  class << self
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
      ENV[env_var_names[key]].presence || dig(:irs, key)
    end
  end
end