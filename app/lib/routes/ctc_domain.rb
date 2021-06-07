module Routes
  class CtcDomain
    def matches?(request)
      app_base_domains = ["localhost", "getyourrefund.org", "staging.getyourrefund.org", "demo.getyourrefund.org"]
      ctc_hosts = app_base_domains.map { |domain| ["ctc.#{domain}", "www.ctc.#{domain}"] }.flatten
      ctc_hosts.include?(request.host)
    end
  end
end
