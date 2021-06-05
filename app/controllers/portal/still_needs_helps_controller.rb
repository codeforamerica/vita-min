module Portal
  class StillNeedsHelpsController < PortalController
    layout "portal"
    before_action :require_client_login
    skip_before_action :redirect_to_still_needs_help_if_necessary

    def edit
      redirect_to portal_root_path unless current_client.triggered_still_needs_help_at.present?
    end

    def update
      return redirect_to portal_root_path unless current_client.triggered_still_needs_help_at.present?

      if current_client.update(update_params)
        if current_client.still_needs_help_yes?
          current_client.tax_returns.where(status: "file_not_filing").each { |tax_return| tax_return.update!(status: "file_hold") }
          InteractionTrackingService.record_incoming_interaction(current_client)
          redirect_to portal_still_needs_help_chat_later_path
        elsif current_client.still_needs_help_no?
          current_client.system_notes.create!(body: "Client indicated that they no longer need tax help")
          InteractionTrackingService.record_incoming_interaction(current_client)
          redirect_to portal_still_needs_help_no_longer_needs_help_path
        end
      else
        render :edit
      end
    end

    def chat_later; end

    def no_longer_needs_help; end

    def experience_survey
      if current_client.update(experience_survey_params)
        redirect_to portal_still_needs_help_no_longer_needs_help_path
      else
        render :no_longer_needs_help
      end
    end

    private

    def update_params
      params.permit(:still_needs_help).merge(triggered_still_needs_help_at: nil)
    end

    def experience_survey_params
      params.require(:client).permit(:experience_survey)
    end
  end
end
