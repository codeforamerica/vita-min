module Routes
  class GyrDomain
    def matches?(request)
      app_base_domains = Rails.application.config.gyr_domains.values
      ctc_domains = app_base_domains.map { |domain| ["www.ctc.#{domain}", "ctc.#{domain}"]  }.flatten
      !ctc_domains.include?(request.host)
    end
  end
end
