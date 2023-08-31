module Routes
  class StateFileDomain
    def matches?(request)
      return false if Rails.env.production?

      MultiTenantService.new(:statefile).host == request.host
    end
  end
end