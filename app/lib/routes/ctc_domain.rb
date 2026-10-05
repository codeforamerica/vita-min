module Routes
  class CtcDomain
    def matches?(request)
      MultiTenantService.new(:ctc).host == request.host
    end
  end
end