require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class IdMe < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://api.id.me',
        :authorize_url => 'https://api.id.me/oauth/authorize',
        :token_url => 'https://api.id.me/oauth/token'
      }
      option :response_type, 'code'

      def request_phase
        super
      end

      def authorize_params
        binding.pry
        super.tap do |params|
          %w[scope response_type client_options].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      uid { raw_info['id'].to_s }

      info do
        {
          'email' => email
        }
      end

      extra do
        {:raw_info => raw_info, :all_emails => emails}
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('user').parsed
      end

      def email
        raw_info['email']
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

OmniAuth.config.add_camelization 'idme', 'IdMe'