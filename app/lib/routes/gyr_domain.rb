module Routes
  class GyrDomain
    def matches?(request)
      app_base_domains = Rails.application.config.gyr_domains.values
      app_base_domains += app_base_domains.map { |domain| "www.#{domain}" }
      app_base_domains.include?(request.host)
    end
  end
end
