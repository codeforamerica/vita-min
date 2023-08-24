module Routes
  class GyrDomain
    def matches?(request)
      !(Routes::CtcDomain.new.matches?(request) || Routes::StateFileDomain.new.matches?(request))
    end
  end
end
