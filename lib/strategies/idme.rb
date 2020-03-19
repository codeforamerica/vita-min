require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class IdMe < OmniAuth::Strategies::OAuth2
      DOMAIN = Rails.env.production? ? "api.id.me" : "api.idmelabs.com"

      option :client_options, {
        :site => "https://#{DOMAIN}",
        :authorize_url => "https://#{DOMAIN}/oauth/authorize?op=signup",
        :token_url => "https://#{DOMAIN}/oauth/token"
      }

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get("api/public/v3/attributes.json").parsed
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

      private

      def fields
        @fields ||= unpack_fields
      end

      def unpack_fields
        fields = raw_info["attributes"].map { |f| [f["handle"].to_sym, f["value"]] }.to_h
        fields[:name] = "#{fields[:fname]} #{fields[:lname]}"
        fields[:first_name] = fields.delete :fname
        fields[:last_name] = fields.delete :lname
        fields[:location] = "#{fields[:city]}, #{fields[:state]}"
        fields[:zip_code] = fields.delete :zip
        fields.merge(raw_info["status"].first.symbolize_keys)
      end
    end
  end
end

OmniAuth.config.add_camelization "idme", "IdMe"
