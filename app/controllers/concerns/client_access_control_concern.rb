module ClientAccessControlConcern
  extend ActiveSupport::Concern

  private

  def require_client_login
    if current_client.blank?
      session[:after_client_login_path] = request.original_fullpath if request.get?
      redirect_to new_portal_client_login_path
    end
  end

  def redirect_to_still_needs_help_if_necessary
    if StillNeedsHelpService.must_show_still_needs_help_flow?(current_client)
      redirect_to portal_still_needs_help_path
    end
  end
end
