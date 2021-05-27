module ClientAccessControlConcern
  extend ActiveSupport::Concern

  private

  def require_client_login
    if current_client.blank?
      session[:after_client_login_path] = request.original_fullpath if request.get?
      redirect_to new_portal_client_login_path and return
    end

    if StillNeedsHelpService.must_show_still_needs_help_flow?(current_client)
      redirect_to portal_still_needs_helps_path
    end
  end
end
