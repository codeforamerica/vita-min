module StateFile
  module StateFileControllerConcern
    extend ActiveSupport::Concern

    included do
      helper_method :current_intake, :current_state_code, :state_name, :current_tax_year
    end

    def current_intake
      StateFile::StateInformationService.active_state_codes
                                        .lazy
                                        .map{ |c| send("current_state_file_#{c}_intake".to_sym) }
                                        .find(&:itself)
    end

    def current_state_code
      if current_intake
        current_intake.state_code
      else
        params[:us_state]
      end
    end

    def state_name
      StateFile::StateInformationService.state_name(current_state_code)
    end

    def current_tax_year
      MultiTenantService.new(:statefile).current_tax_year
    end
  end
end