module OmniAuth
  module Strategies
    autoload :Zendesk, Rails.root.join("lib", "strategies", "zendesk.rb")
  end

  Rails.application.config.middleware.use Builder do
    provider(
      :zendesk,
      EnvironmentCredentials.dig(:zendesk_oauth, :client_id),
      EnvironmentCredentials.dig(:zendesk_oauth, :client_secret),
      scope: "read"
    )
  end
end
