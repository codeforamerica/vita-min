module StateFile
  module StateFileControllerConcern
    extend ActiveSupport::Concern

    included do
      helper_method :current_tax_year, :current_intake
    end

    def current_intake
      StateFile::StateInformationService.active_state_codes
                                        .lazy
                                        .map { |c| send("current_state_file_#{c}_intake".to_sym) }
                                        .find(&:itself)
    end

    def current_tax_year
      MultiTenantService.new(:statefile).current_tax_year
    end
  end
end