module OmniAuth
  module Strategies
    autoload :IdMe, Rails.root.join("lib", "strategies", "idme.rb")
    autoload :Zendesk, Rails.root.join("lib", "strategies", "zendesk.rb")
  end

  Rails.application.config.middleware.use Builder do
    provider(
      :zendesk,
      EnvironmentCredentials.dig(:zendesk_oauth, :client_id),
      EnvironmentCredentials.dig(:zendesk_oauth, :client_secret),
      scope: "read"
    )

    provider(
      :id_me,
      EnvironmentCredentials.dig(:idme, :client_id),
      EnvironmentCredentials.dig(:idme, :client_secret),
      scope: Rails.env.production? ? "identity" : "ial2"
    )
  end
end