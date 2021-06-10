module Routes
  class CtcDomain
    def matches?(request)
      app_ctc_domains = Rails.application.config.ctc_domains.values
      app_ctc_domains += app_ctc_domains.map { |domain| "www.#{domain}" }
      app_ctc_domains.include?(request.host)
    end
  end
end
