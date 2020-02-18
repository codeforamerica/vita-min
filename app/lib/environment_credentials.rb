class EnvironmentCredentials
  class << self
    def dig(*keys)
      env_symbol = Rails.env.to_sym
      Rails.application.credentials.dig(env_symbol, *keys)
    end
  end
end