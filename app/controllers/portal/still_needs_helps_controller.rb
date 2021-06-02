module Portal
  class StillNeedsHelpsController < PortalController
    layout "portal"
    before_action :require_client_login
    skip_before_action :redirect_to_still_needs_help_if_necessary

    def edit; end

    def update
      if update_params[:still_needs_help] == "yes"
        if current_client.triggered_still_needs_help_at.present?
          current_client.update!(triggered_still_needs_help_at: nil, still_needs_help: "yes")
          current_client.tax_returns.where(status: "file_not_filing").each { |tax_return| tax_return.update!(status: "file_hold") }
          InteractionTrackingService.record_incoming_interaction(current_client)
        end

        redirect_to portal_still_needs_help_yes_path
      else
        current_client.system_notes.create!(body: "Client indicated that they no longer need tax help")
        InteractionTrackingService.record_incoming_interaction(current_client)
        redirect_to portal_still_needs_help_no_path
      end
    end

    def yes
      render html: "No content"
    end

    def no
      render html: "No content"
    end

    private

    def update_params
      params.permit(:still_needs_help)
    end
  end
end
