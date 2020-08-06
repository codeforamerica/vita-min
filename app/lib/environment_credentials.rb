class EnvironmentCredentials
  class << self
    def dig(*keys)
      Rails.application.credentials.dig(*keys)
    end
  end
end