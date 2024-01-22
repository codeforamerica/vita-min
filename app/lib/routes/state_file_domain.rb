module Routes
  class StateFileDomain
    def matches?(request)
      MultiTenantService.new(:statefile).host == request.host
    end
  end
end