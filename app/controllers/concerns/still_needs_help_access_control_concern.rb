module StillNeedsHelpAccessControlConcern
  extend ActiveSupport::Concern

  private

  def require_still_needs_help_client_login
    if current_client.nil?
      session[:after_client_login_path] = request.original_fullpath if request.get?
      redirect_to new_portal_client_login_path and return
    end

    redirect_to portal_root_path unless StillNeedsHelpService.may_show_still_needs_help_flow?(current_client)
  end
end
