module Routes
  class CtcDomain
    def matches?(request)
      Rails.application.config.ctc_domains.values.include?(request.host)
    end
  end
end
