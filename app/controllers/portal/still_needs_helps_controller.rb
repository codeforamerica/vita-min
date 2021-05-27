module Portal
  class StillNeedsHelpsController < ApplicationController
    include StillNeedsHelpAccessControlConcern
    before_action :require_still_needs_help_client_login
    layout "application"

    def index
      render html: "Are you still interested in filing your taxes with us?"
    end
  end
end
