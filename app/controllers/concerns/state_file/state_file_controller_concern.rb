module StateFile
  module StateFileControllerConcern
    extend ActiveSupport::Concern

    included do
      helper_method :state_name, :state_code
    end

    private

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
  end
end
