module Routes
  class StateFileDomain
    def matches?(request)
      return false if Rails.env.production?

      MultiTenantService.new(:state_file).host == request.host
    end
  end
end