module StateFile
  module StateFileControllerConcern
    extend ActiveSupport::Concern

    included do
      helper_method :current_tax_year
    end

    def current_tax_year
      MultiTenantService.new(:statefile).current_tax_year
    end
  end
end