module StateFile
  module StateFileControllerConcern
    extend ActiveSupport::Concern

    included do
      helper_method(
        :current_tax_year, :filer_count, :state_name, :state_abbr, :ny?, :az?, :state_param
      )
    end

    private

    def state_name
      unless StateFile::StateInformationService::ACTIVE_STATES.include?(state_param)
        raise StandardError, state_param
      end
      States.name_for_key(state_param&.upcase)
    end

    # TODO consolidate this with state_param
    def state_code
      unless StateFile::StateInformationService::ACTIVE_STATES.include?(state_param)
        raise StandardError, state_param
      end
      state_param
    end

    def state_param
      params[:us_state]
    end

    def ny?
      state_param == "ny"
    end

    def az?
      state_param == "az"
    end

    def service_type
      case state_param
      when "az" then :statefile_az
      when "ny" then :statefile_ny
      end
    end

    def tenant_service
      MultiTenantService.new(service_type)
    end

    def current_tax_year
      tenant_service.current_tax_year
    end

    def filer_count
      current_intake&.filer_count
    end
  end
end
