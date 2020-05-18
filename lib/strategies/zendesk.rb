require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Zendesk < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => "https://eitc.zendesk.com",
        :authorize_url => "https://eitc.zendesk.com/oauth/authorizations/new",
        :token_url => "https://eitc.zendesk.com/oauth/tokens"
      }

      option :authorize_params, {
        response_type: "code"
      }

      def token_params
        super.merge(
          client_id: EnvironmentCredentials.dig(:zendesk_oauth, :client_id),
          client_secret: EnvironmentCredentials.dig(:zendesk_oauth, :client_secret),
          redirect_uri: full_host + script_name + callback_path,
          grant_type: "authorization_code",
          scope: "read"
        )
      end

      def raw_info
        zendesk_client.current_user
      end

      def zendesk_client
        @_zendesk_client ||= ZendeskAPI::Client.new do |client|
          client.access_token = access_token.token
          client.url = "https://eitc.zendesk.com/api/v2"
        end
      end

      uid { raw_info.id }

      info do
        user = raw_info
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role.name,
          organization_id: user.organization_id,
          ticket_restriction: user["ticket_restriction"],
          two_factor_auth_enabled: user["two_factor_auth_enabled"],
          active: user["active"],
          suspended: user["suspended"],
          verified: user["verified"]
        }
      end

      extra do
        { "raw_info" => raw_info }
      end
    end
  end
end
