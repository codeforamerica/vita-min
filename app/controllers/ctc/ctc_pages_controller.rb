module Ctc
  class CtcPagesController < ApplicationController
    def home
      send_mixpanel_event(event_name: 'getctcarchive', data: {})
      redirect_to MultiTenantService::gyr.url, allow_other_host: true
    end
  end
end
