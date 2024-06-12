# TODO i left these things in here because this concern exists but the thing is the concern is only included once (in the state file questions controller) so should we just move all this over to the controller itself?
module StateFile
  module StateFileControllerConcern
    extend ActiveSupport::Concern

    included do
      helper_method :current_tax_year, :state_name, :state_code
    end

    def state_code
      state_from_params = params[:us_state]
      unless StateFile::StateInformationService.active_states.include?(state_from_params)
        raise StandardError, state_from_params
      end
      state_from_params
    end

    def state_name
      StateFile::StateInformationService.state_name(state_code)
    end

    def current_tax_year
      MultiTenantService.new(:statefile).current_tax_year
    end
  end
end
