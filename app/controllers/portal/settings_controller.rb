module Portal
  class SettingsController < PortalController
    def show
      @intake = current_intake
    end
  end
end
