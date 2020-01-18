require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class IdMe < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://api.idmelabs.com',
        :authorize_url => 'https://api.idmelabs.com/oauth/authorize',
        :token_url => 'https://api.idmelabs.com/oauth/token'
      }
      option :response_type, 'code'

      def request_phase
        super
      end

      def authorize_params
        super.tap do |params|
          %w[scope response_type client_options client_id client_secret].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      uid { fields[:uuid] }

      info do
        fields
      end

      extra do
        {
          raw_info: raw_info,
        }
      end

      def fields
        @fields ||= unpack_fields
      end

      def unpack_fields
        fields = raw_info["attributes"].map { |f| [f["handle"].to_sym, f["value"]] }.to_h
        fields[:name] = "#{fields[:fname]} #{fields[:lname]}"
        fields[:first_name] = fields.delete :fname
        fields[:last_name] = fields.delete :lname
        fields[:location] = "#{fields[:city]}, #{fields[:state]}"
        fields.merge(raw_info["status"].first.symbolize_keys)
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('api/public/v3/attributes.json').parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

OmniAuth.config.add_camelization 'idme', 'IdMe'