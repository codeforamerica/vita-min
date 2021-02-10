module Diy
  class LocationController < DiyController
    skip_before_action :require_diy_intake

    def current_diy_intake
      DiyIntake.new(
        source: source,
        referrer: referrer,
        locale: I18n.locale,
        visitor_id: cookies[:visitor_id]
      )
    end

    private
    def after_update_success
      session[:diy_intake_id] = @form.diy_intake.id
    end
  end
end