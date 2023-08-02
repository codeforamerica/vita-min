module Routes
  class StateFileDomain
    def matches?(request)
      MultiTenantService.new(:state_file).host == request.host
    end
  end
end