module Hub
  class TrustedProxiesController < Hub::BaseController
    load_and_authorize_resource class: false
    def index
      render plain: Rails.application.config.action_dispatch.trusted_proxies.map { |ip_address| "#{ip_address.to_s}/#{ip_address.prefix}" }.join("\n")
    end
  end
end
