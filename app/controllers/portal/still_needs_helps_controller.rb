module Portal
  class StillNeedsHelpsController < PortalController
    layout "portal"
    before_action :require_client_login
    skip_before_action :redirect_to_still_needs_help_if_necessary

    def edit; end

    def update
      if update_params[:still_needs_help] == "yes" && current_client.triggered_still_needs_help_at.present?
        current_client.update!(triggered_still_needs_help_at: nil, first_unanswered_incoming_interaction_at: Time.now)
        redirect_to portal_still_needs_help_yes_path
      else
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
